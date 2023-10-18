'
'
' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2000
' ####################  Windows XBasic development environment
'
' subject to GPL license - see COPYING
'
' maxreason@maxreason.com
'
' for Windows XBasic
'
'
PROGRAM	"xit"
VERSION	"0.0370"
'
IMPORT	"xst"
IMPORT	"xin"
IMPORT	"xma"
IMPORT	"xcm"
IMPORT	"xgr"
IMPORT	"xui"
IMPORT	"xlib"
IMPORT	"kernel32"
IMPORT	"xut"
IMPORT	"xutpde"
'
'
' *********************************
' *****  Xit COMPOSITE TYPES  *****
' *********************************
'
TYPE FRAMEINFO
	XLONG				.frameAddr							' base frame pointer
	XLONG				.funcAddr								' execution address
	XLONG				.funcNumber							' function number / -1
	XLONG				.funcLine								' line number in function
END TYPE
'
'
' ***************************************
' *****  WindowsNT COMPOSITE TYPES  *****
' ***************************************
'
TYPE EXCEPTION_RECORD									' defined in \mstools\h\winnt.h
	XLONG		.exceptionCode							' NT exception code
	XLONG		.exceptionFlags							' 1 = EXCEPTION_NONCONTINUABLE
	XLONG		.ptrExceptionRecord					' nested exceptions
	XLONG		.exceptionAddress						' address where exception occurred
	XLONG		.numberParameters						' # parameters in following array: (0...)
	XLONG		.exceptionInformation[14]		' EXCEPTION_MAXIMUM_PARAMETERS
END TYPE
'
TYPE FLOATING_SAVE_AREA								' used below in TYPE CONTEXT
	XLONG		.controlWord
	XLONG		.statusWord
	XLONG		.tagWord
	XLONG		.errorOffset
	XLONG		.errorSelector
	XLONG		.dataOffset
	XLONG		.dataSelector
	UBYTE		.registerArea[79]						' SIZE_OF_80387_REGISTERS
	XLONG		.cr0NpxState
END TYPE
'
'	CONTEXT Frame       (from \mstools\h\winnt.h)
'
'	This frame has several purposes:
'   1) it is used as an argument to NtContinue
'   2) is is used to constuct a call frame for APC delivery
'		3) it is used in the user level thread creation routines.
'
'	The layout of the record conforms to a standard call frame.
'
TYPE EXCEPTION_CONTEXT
'
'	The flags values within this flag control the contents of
'		a CONTEXT record.
'
'	If the context record is used as an input parameter, then
'		for each portion of the context record controlled by a flag
'		whose value is set, it is assumed that that portion of the
'		context record contains valid context. If the context record
'		is being used to modify a threads context, then only that
'		portion of the threads context will be modified.
'
'	If the context record is used as an IN OUT parameter to capture
'		the context of a thread, then only those portions of the thread's
'		context corresponding to set flags will be returned.
'
'	The context record is never used as an OUT only parameter.
'
	XLONG		.contextFlags
'
' This section is specified/returned if CONTEXT_DEBUG_REGISTERS is
' set in ContextFlags.  Note that CONTEXT_DEBUG_REGISTERS is NOT
' included in CONTEXT_FULL.
'
	XLONG		.dr0
	XLONG		.dr1
	XLONG		.dr2
	XLONG		.dr3
	XLONG		.dr6
	XLONG		.dr7
'
'	This section is specified/returned if the
'	ContextFlags word contains the flag CONTEXT_FLOATING_POINT.
'
	FLOATING_SAVE_AREA		.floatSave
'
'	This section is specified/returned if the
'	ContextFlags word contains the flag CONTEXT_SEGMENTS.
'
	XLONG		.segGs
	XLONG		.segFs
	XLONG		.segEs
	XLONG		.segDs
'
'	This section is specified/returned if the
'	ContextFlags word contains the flag CONTEXT_INTEGER.
'
	XLONG		.edi
	XLONG		.esi
	XLONG		.ebx
	XLONG		.edx
	XLONG		.ecx
	XLONG		.eax
'
'	This section is specified/returned if the
'	ContextFlags word contains the flag CONTEXT_CONTROL.
'
	XLONG		.ebp
	XLONG		.eip
	XLONG		.segCs							' MUST BE SANITIZED
	XLONG		.eFlags							' MUST BE SANITIZED
	XLONG		.esp
	XLONG		.segSs
END TYPE
'
'
' *****************************
' *****  Entry and Setup  *****
' *****************************
'
DECLARE FUNCTION  Xit										(argc, argv, envp)
DECLARE FUNCTION  XitMain								(sigCode, sigInfo)		' xexcept.c
DECLARE FUNCTION  XitVersion$						()
'
INTERNAL FUNCTION  Welcome							()
INTERNAL FUNCTION  FreeAliens						()
INTERNAL FUNCTION  InitGui							()
INTERNAL FUNCTION  InitProgram					()
INTERNAL FUNCTION  Message							(message$)
INTERNAL FUNCTION  PrintMenu						()
INTERNAL FUNCTION  XitBlowback					()
INTERNAL FUNCTION  UserBlowback					()
INTERNAL FUNCTION  XitQuit							(status)
INTERNAL FUNCTION  MakeUserCodeSpace		(theSize)
'
'
' *****************************
' *****  Debug Functions  *****
' *****************************
'
INTERNAL FUNCTION  DisplayRegisters			()
INTERNAL FUNCTION  Dump$								(addr$, xsize$)
INTERNAL FUNCTION  Fill									(start$, xsize$, value$)
INTERNAL FUNCTION  Frames$							()
INTERNAL FUNCTION  Go										()					' execute app/compiler
INTERNAL FUNCTION  Locate$							(value$)
INTERNAL FUNCTION  MemoryMap$						()
INTERNAL FUNCTION  SetAlarm							(millisec)	' Not called in NT
INTERNAL FUNCTION  Substitute						(addr)
INTERNAL FUNCTION  UserGo								()
'
' *************************************
' *****  Debug Utility Functions  *****
' *************************************
'
INTERNAL FUNCTION  AddressOk						(addr)
INTERNAL FUNCTION  ChangeRegister				(reg[], arg0$, arg1$)
INTERNAL FUNCTION  ClearRegisters				()
INTERNAL FUNCTION  ParseLine$						(command$, args$[])
INTERNAL FUNCTION  RegisterString$			()
'
' *******************************
' *****  Testing Functions  *****
' *******************************
'
INTERNAL FUNCTION  CountHeaders					()
INTERNAL FUNCTION  Headers							(pointersBaseAddr, headersBaseAddr)
INTERNAL FUNCTION  MissingHeader				(addr, headers[], limit)
INTERNAL FUNCTION  PrintHeader					(addr, ua, da, ul, dl)
INTERNAL FUNCTION  TestHeaders					()
'
' **********************************
' *****  Breakpoint Functions  *****
' **********************************
'
INTERNAL FUNCTION  BreakContinuePrep		(command, func, continueAddr)
INTERNAL FUNCTION  BreakPatch						()
INTERNAL FUNCTION  BreakPatchAll				(startAddr)
INTERNAL FUNCTION  BreakPatchLog				(patchAddr, patchCode)
'
'
' **************************************
' *****  Error Reporting Functions *****
' **************************************
'
INTERNAL FUNCTION  GetRuntimeError			(runtimeInfo$, runtimeMsg$)
INTERNAL FUNCTION  WarningResponse			(message$, okButton$, optionButton$)
'
'#endXitDbg
'
' *******************
' *****  Setup  *****
' *******************
'
INTERNAL FUNCTION  XitCrash							(sigNumber, sxip, fatal)
'
'
' ********************************
' *****  INTERNAL Utilities  *****
' ********************************
'
INTERNAL FUNCTION  AssemblyString$			(funcNumber, lineNumber)
INTERNAL FUNCTION  MainLoop							(exitFlagAddr)
INTERNAL FUNCTION  ClearMessageQueue		()
INTERNAL FUNCTION  AddDispatch					(funcAddress, arg)
INTERNAL FUNCTION  Dispatch							()
INTERNAL FUNCTION  EnableAbortSignals		()
'
'
' ********************************
' *****  Breakpoint Control  *****
' ********************************
'
INTERNAL FUNCTION  BreakClearArrays			()
INTERNAL FUNCTION  BreakInternal				(command, func, line, addr)
INTERNAL FUNCTION  BreakProgrammer			(command, addr, func)
INTERNAL FUNCTION  GetFuncAndLineNumberAtThisAddress	(addr)
'
'
' **************************************
' *****  USER INTERFACE FUNCTIONS  *****
' **************************************
'
INTERNAL FUNCTION  XitExecute						()
INTERNAL FUNCTION  CreateWindows				()
INTERNAL FUNCTION  InitWindows					()
INTERNAL FUNCTION  AlignWindow					(grid, align)
INTERNAL FUNCTION  HideWindow						(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  Environment					(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  EnvironmentCode			(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  WelcomeWindowCode		(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitCEO								(grid, message, v0, v1, v2, v3, r0, ANY)
'
'
' **********************************
' *****  Xit Custom GUI Boxes  *****
' **********************************
'
INTERNAL FUNCTION  XitArray							(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitAssembly					(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitComposite					(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  Xit2LineDialog				(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitErrorCompile			(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitErrorRuntime			(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitFind							(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitFrames						(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitMemory						(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitOptionMisc				(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitRegisters					(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitString						(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitTextCursor				(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  XitVariables					(grid, message, v0, v1, v2, v3, r0, ANY)
'
' ********************************
' *****  Xit Menu Functions  *****
' ********************************
'
INTERNAL FUNCTION  AddCommandItem				(text$)
INTERNAL FUNCTION  ImmediateMode				(keyState)
'
INTERNAL FUNCTION  FileNew							(mode)
INTERNAL FUNCTION  FileTextLoad					(skipUpdate)
INTERNAL FUNCTION  FileLoad							(skipUpdate)
INTERNAL FUNCTION  FileSave							(skipUpdate)
INTERNAL FUNCTION  FileMode							(mode)
INTERNAL FUNCTION  FileRename						(skipUpdate)
INTERNAL FUNCTION  FileQuit							()
'
INTERNAL FUNCTION  EditCut							(bufferNumber)
INTERNAL FUNCTION  EditGrab							(bufferNumber)
INTERNAL FUNCTION  EditPaste						(bufferNumber)
INTERNAL FUNCTION  EditFind							(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  FindSearch						()
INTERNAL FUNCTION  ReplaceSearch				()
INTERNAL FUNCTION  EditRead							(skipUpdate)
INTERNAL FUNCTION  EditWrite						(skipUpdate)
INTERNAL FUNCTION  EditAbandon					()
'
INTERNAL FUNCTION  ViewFunc												(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  ViewPriorFunc									()
INTERNAL FUNCTION  ViewNewFunc										(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  ViewDeleteFunc									(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  ViewRenameFunc									(skipUpdate)
INTERNAL FUNCTION  ViewCloneFunc									(skipUpdate)
INTERNAL FUNCTION  ViewLoadFunc										(skipUpdate)
INTERNAL FUNCTION  ViewSaveFunc										(skipUpdate)
INTERNAL FUNCTION  ViewMergePROLOG								(skipUpdate)
INTERNAL FUNCTION  ViewImportFunctionFromProgram	(skipUpdate)
'
INTERNAL FUNCTION  XitOptionMiscCode		(grid, message, v0, v1, v2, v3, kid, ANY)
INTERNAL FUNCTION  OptionTabWidth				(width)
INTERNAL FUNCTION  OptionTextCursor			(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  OptionFont						()
'
INTERNAL FUNCTION  RunStart							()
INTERNAL FUNCTION  ClearForCompile			()
INTERNAL FUNCTION  CompileProgram				()
INTERNAL FUNCTION  RunContinue					()
INTERNAL FUNCTION  RunJump							()
INTERNAL FUNCTION  RunPause							()
INTERNAL FUNCTION  RunKill							()
INTERNAL FUNCTION  RunRecompile					()
INTERNAL FUNCTION  CompileAssembly			()
INTERNAL FUNCTION  RunAssembly					()
INTERNAL FUNCTION  RunLibrary						()
'
INTERNAL FUNCTION  DebugToggle					()
INTERNAL FUNCTION  DebugClear						()
INTERNAL FUNCTION  DebugErase						()
INTERNAL FUNCTION  DebugMemory					(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  DebugAssembly				(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  DebugRegisters				(grid, message, v0, v1, v2, v3, r0, ANY)
'
INTERNAL FUNCTION  ClearErrors					()
INTERNAL FUNCTION  UpdateErrors					(func, line)
INTERNAL FUNCTION  WizardCompErrors			(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  WizardRunErrors			(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  ClearRuntimeError		()
INTERNAL FUNCTION  UpdateRuntimeError		()
'
INTERNAL FUNCTION  HelpIndex						()
INTERNAL FUNCTION  HelpContents					()
INTERNAL FUNCTION  HelpHighlight				()
INTERNAL FUNCTION  HelpAbout						(display)
'
' **********************************
' *****  HOT BUTTON FUNCTIONS  *****
' **********************************
'
INTERNAL FUNCTION  HotToCursor								()
INTERNAL FUNCTION  HotStepLocal								()
INTERNAL FUNCTION  HotStepGlobal							()
INTERNAL FUNCTION  HotVariables								(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  UpdateVariables						()
INTERNAL FUNCTION  VariablesFind							()
INTERNAL FUNCTION  VariablesNewValue					()
INTERNAL FUNCTION  VariablesDetail						()
INTERNAL FUNCTION  VariablesArray							(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  VariablesArrayDisplay			(action)
INTERNAL FUNCTION  VariablesArrayIndex				()
INTERNAL FUNCTION  VariablesArrayElement			()
INTERNAL FUNCTION  VariablesArrayDetail				()
INTERNAL FUNCTION  VariablesString						(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  VariablesComposite					(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  VariablesCompositeDisplay	(action)
INTERNAL FUNCTION  VariableSort								(tok[], symbol$[], reg[], addr[], Low, High)
INTERNAL FUNCTION  HotFrames									(grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  UpdateFrames								()
INTERNAL FUNCTION  Pop16Frames								(signalCode, signalInfo)
'
' ***********************************************
' *****  APPLICATION DEVELOPMENT FUNCTIONS  *****
' ***********************************************
'
DECLARE FUNCTION  XitGetDECLARE               (funcName$, declare$)
DECLARE FUNCTION  XitGetDisplayedFunction     (funcName$)
DECLARE FUNCTION  XitGetFunction              (funcName$, text$[])
DECLARE FUNCTION  XitLoadFunction             (funcName$, fileName$)
DECLARE FUNCTION  XitMergePROLOG              (fileName$)
DECLARE FUNCTION  XitNewProgram               ()
DECLARE FUNCTION  XitQueryFunction            (funcName$, exists)
DECLARE FUNCTION  XitQueryProgram             (status)
DECLARE FUNCTION  XitSetDECLARE               (funcName$, declare$)
DECLARE FUNCTION  XitSetDisplayedFunction     (funcName$)
DECLARE FUNCTION  XitSetFunction              (funcName$, text$[])
DECLARE FUNCTION  XitSaveFunction             (funcName$, fileName$)
DECLARE FUNCTION  XitSoftBreak                ()
DECLARE FUNCTION  XxxAsm$                     (addr, length)
DECLARE FUNCTION  XxxAnyAsm$                  (addr, length)	' no address check
DECLARE FUNCTION  XxxXitGetUserProgramName    (@program$)
DECLARE FUNCTION  XxxSetBlowback              ()
'
'
' ***************************************
' ***************************************
' *****  GENERIC SUPPORT FUNCTIONS  *****
' ***************************************
' ***************************************
'
INTERNAL FUNCTION  CheckDECLARE								(tok[], declareFuncNumber)
INTERNAL FUNCTION  CloneDECLARE								(srcFuncNumber, newFuncNumber)
INTERNAL FUNCTION  CompileLine								(funcNumber, lineNumber,tok[])
INTERNAL FUNCTION  ConvertProgToText					(mode, crlf, abortAllowed, ANY)
INTERNAL FUNCTION  ConvertTextToProg					(mode, ANY, abortAllowed)
INTERNAL FUNCTION  DefaultFunctionText				(funcNumber, text$[])
INTERNAL FUNCTION  Display										(funcNumber, cursorLine, cursorPos, topLine, topIndent)
INTERNAL FUNCTION  FindArray                  (mode, text$[], find$, line, pos, reps, skip, matches[])
INTERNAL FUNCTION  FunctionNameToNumber				(funcName$, funcNumber)
INTERNAL FUNCTION  GetFuncNumberGivenAddress	(addr)
INTERNAL FUNCTION  SetCursor									(cursor)
INTERNAL FUNCTION  InitializeCompiler					()
INTERNAL FUNCTION  LoadLineCodeArray					()
INTERNAL FUNCTION  NextXitToken								(tok[], tokPtr, lastTok,token)
INTERNAL FUNCTION  RemoveExeLinePtr						()
INTERNAL FUNCTION  ReplaceArray               (mode, text$[], find$, replace$, line, pos, reps, skip)
INTERNAL FUNCTION  ResetDataDisplays					(action)
INTERNAL FUNCTION  RestoreTextToProg					(redisplay, reportBogusRename)
INTERNAL FUNCTION  SetCurrentStatus						(status, line)
INTERNAL FUNCTION  SetDataDisplays						()
INTERNAL FUNCTION  SetEntryFunction						()
INTERNAL FUNCTION  SetExeLinePtr							()
INTERNAL FUNCTION  SortFunctionNames					(name$[], includePROLOG)
INTERNAL FUNCTION  TextHasNonWhites						(mode, ANY)
INTERNAL FUNCTION  TextToTokenArray						(text$[], func[], funcNumber, freeze)
INTERNAL FUNCTION  TokenArrayToText						(funcNumber, text$[])
INTERNAL FUNCTION  UpdateFileFuncLabels				(updateFile, updateFunc)
'
' compiler functions
'
EXTERNAL FUNCTION  Xnt                        ()
EXTERNAL FUNCTION  XxxCheckLine               (lineNumber, @tok[])
EXTERNAL FUNCTION  XxxCompilePrep             ()
EXTERNAL FUNCTION  XxxCreateCompileFiles      ()
EXTERNAL FUNCTION  XxxDeleteFunction          (funcNumber)
EXTERNAL FUNCTION  XxxDeparser                (@tok[], @asm$)
EXTERNAL FUNCTION  XxxDeparseFunction         (@text$, @func[], lastLine, flags)
EXTERNAL FUNCTION  XxxErrorInfo               (xerror, @rawPtr, @srcPtr, @srcLine$)
EXTERNAL FUNCTION  XxxFunctionName            (command, @funcName$, editFunction)
EXTERNAL FUNCTION  XxxGetAddressGivenLabel    (label$)
EXTERNAL FUNCTION  XxxGetFunctionVariables    (showFuncNumber, @kinds[], @varTok[], @varSymbol$[], @varReg[], @varAddr[])
EXTERNAL FUNCTION  XxxGetLabelGivenAddress    (addr, @labels$[])
EXTERNAL FUNCTION  XxxGetPatchErrors          (@symbol$[], @token[], @addr[])
EXTERNAL FUNCTION  XxxGetProgramName          (program$)
EXTERNAL FUNCTION  XxxGetUserTypes            (varTypes$[])
EXTERNAL FUNCTION  XxxGetXerror$              (error)
EXTERNAL FUNCTION  XxxInitAll                 ()
EXTERNAL FUNCTION  XxxInitParse               ()
EXTERNAL FUNCTION  XxxInitVariablesPass1      ()
EXTERNAL FUNCTION  XxxParseSourceLine         (@token$, @tok[])
EXTERNAL FUNCTION  XxxPassFunctionArrays      (command, @funcSymbol$[], @funcToken[], @funcScope[])
EXTERNAL FUNCTION  XxxPassTypeArrays          (command, @pSize[], @pSize$[], @pAlias[], @pAlign[], @pSymbol$[], @pToken[], @pEleCount[], @pEleSymbol$[], @pEleToken[], @pEleAddr[], @pEleSize[], @pEleType[], @pEleStringSize[], @pEleUBound[])
EXTERNAL FUNCTION  XxxSetProgramName          (program$)
EXTERNAL FUNCTION  XxxTheType                 (token, funcNumber)
EXTERNAL FUNCTION  XxxXBasic                  ()
EXTERNAL FUNCTION  XxxXBasicVersion$          ()
EXTERNAL FUNCTION  XxxXntInitLibraries        ()
EXTERNAL FUNCTION  XxxXntBlowback             ()
'
' standard library functions
'
EXTERNAL FUNCTION  XxxXstBlowback             ()
EXTERNAL FUNCTION  XxxGetVersion              ()
EXTERNAL FUNCTION  XxxXstFreeLibrary          (lib$, handle)
EXTERNAL FUNCTION  XxxXstLoadLibrary          (lib$)
EXTERNAL FUNCTION  XxxCloseAllUser            ()
EXTERNAL FUNCTION  Xio						            ()
'
' network library functions
'
EXTERNAL FUNCTION  XxxXinBlowback             ()
'
' disassembler functions
'
EXTERNAL FUNCTION  Xdis                       ()
EXTERNAL FUNCTION  XxxDisassemble$            (addr, mode)
'
' GraphicsDesigner library functions
'
EXTERNAL FUNCTION  XxxXgrBlowback             ()
EXTERNAL FUNCTION  XxxXgrQuit                 ()
EXTERNAL FUNCTION  XxxXgrReleaseMice          ()
'
' GuiDesigner library functions
'
EXTERNAL FUNCTION  XxxGuiDesignerOnOff        (state)
EXTERNAL FUNCTION  XxxXuiBlowback             ()
EXTERNAL FUNCTION  XxxXuiTextCursor           (color)
'
'
' *********************************
'	*****  C Library Functions  *****
' *********************************
'
EXTERNAL CFUNCTION  free											(addr)
EXTERNAL CFUNCTION  calloc										(bytes)
EXTERNAL CFUNCTION  malloc										(bytes)
EXTERNAL CFUNCTION  realloc										(oldAddr, newSize)
EXTERNAL CFUNCTION  recalloc									(oldAddr, newSize)
EXTERNAL CFUNCTION  system										(command)			' SHELL ()
'
'
' *****  Win32 Constants  *****
'
	$$MEM_COMMIT			= 0x00001000		' for VirtualAlloc()
	$$MEM_RESERVE			= 0x00002000
	$$MEM_DECOMMIT		= 0x00004000
	$$MEM_RELEASE			= 0x00008000
	$$MEM_FREE				= 0x00010000
	$$MEM_PRIVATE			= 0x00020000
	$$PAGE_NOACCESS		= 0x00000001
	$$PAGE_READONLY		= 0x00000002
	$$PAGE_READWRITE	= 0x00000004
'
'#begXitDbg
'
'
' **********************
'	*****  Constants *****
' **********************
'
'	UNIX constants
'
	$$U_SEEK_SET			= 0								' LSEEK
	$$U_SEEK_CUR			= 1
	$$U_SEEK_END			= 2
'
	$$FatalSignalInEnv		= 1							' Fatal signals
	$$FatalSigQuitInAllo	= 2
'
	$$Unspecified					= 0
	$$Text								= 1							' active file type
	$$Program							= 2							' See XitQueryProgram()
	$$GuiProgram					= 3							' See FileNew()
'
	$$TextString					= 0							' text <-> prog conversion
	$$TextArray						= 1
	$$AbortAllowed				= $$TRUE
	$$AbortNotAllowed			= $$FALSE
'
'	$$BREAK	= 0xF000D1FE				' 88k Op Code that causes a BREAKPOINT trap
'															' SIGTRAP #510 (signal frame argument is 510)
'															' SYSTEMCALL softBreak traps are #509
'
' 80386 "int3" breakpoint opcode 0xCC is NOP in Win32s
' Tried 1 byte illegal instructions instead of 0xCC
'   They are also NOPs on Win32s : 0x82, 0xD6, 0xF1
'		CompileProgram() guarantees minimum of 2 bytes per source line
'
'		note: 0x0F0F no longer works reliably (?on Pentiums?)
'					0xF00F looks like it works, however...
'
	$$BREAK1 = 0xCC			' Win32  : 1-byte "int3" breakpoint
	$$BREAK2 = 0xF00F		' Win32s : 0xF00F invalid opcode for breakpoint
'	$$BREAK2 = 0x0F0F		' Win32s : 0x0F0F invalid opcode for breakpoint
'
' $$BREAK : see BreakProgrammer() and BreakInternal()
'
	$$BreakRemoveAll					=  0
	$$BreakRemoveOne					=  1
	$$BreakInstallAll					=  2
	$$BreakInstallFunc				=  3
	$$BreakInstallOne					=  4
	$$BreakGetFuncLineOpcode	=  5
	$$BreakGetOpcode					=  6
	$$BreakClearAll						=  7
	$$BreakClearFunc					=  8
	$$BreakClearOne						=  9
	$$BreakSetOne							= 10
	$$BreakCheckOne						= 11
	$$BreakContinueRunning		=  0
	$$BreakContinueStepLocal	=  1
	$$BreakContinueStepGlobal	=  2
	$$BreakContinueToCursor		=  3
'
	$$IPC_PRIVATE	=  0										' shmget (private page)
	$$SC_SHMMAXSZ	= 16										' sysconf: max size of shared segment
	$$SC_SHMSEGS	= 17										' sysconf: max number of attached segs
'
	$$StatusAssembling		= 0							' environment status
	$$StatusCompiled			= 1
	$$StatusCompiling			= 2
	$$StatusDecoding			= 3
	$$StatusDeparsing			= 4
	$$StatusEditing				= 5
	$$StatusFormatting		= 6
	$$StatusInitializing	= 7
	$$StatusLoading				= 8
	$$StatusParsing				= 9
	$$StatusPaused				= 10
	$$StatusRecompiling		= 11
	$$StatusRunning				= 12
	$$StatusSaving				= 13
	$$StatusSearching			= 14
	$$StatusXit						= 15
	$$StatusInline				= 16						' User program is waiting in INLINE$()
'
	$$WarningProceed			= 1							' for warning response
	$$WarningOption				= 2
	$$WarningCancel				= 3
'
	$$ResetAssembly				= 1							' For ResetDataDisplays()
	$$InitiatingRun				= 2							'						"
'
	$$XGET								= 0							' compiler function commands
	$$XSET								= 1
'
	$$NUMBER							= BITFIELD (16, 0)
	$$WORD0								= BITFIELD (16, 0)
	$$WORD1								= BITFIELD (16, 16)
	$$BYTE0								= BITFIELD (8, 0)
	$$BYTE1								= BITFIELD (8, 8)
	$$BYTE2								= BITFIELD (8, 16)
	$$BYTE3								= BITFIELD (8, 24)
'
	$$StateContents				= BITFIELD (2, 20)
'
' *****************************
' *****  Xit Error Codes  *****
' *****************************
'
	$$XitEnvironmentInactive	= 1				' Application management errors
	$$XitTextMode							= 2
	$$XitProgramRunning				= 3
	$$XitIllegalFunctionName	= 4
	$$XitFunctionUndefined		= 5
	$$XitMismatchedArguments	= 6				' Last error < ##ERROR: file errors
'
' ********************************
' *****  Compiler Constants  *****
' ********************************
'
	$$T_STARTS						= 0x11000000
	$$KIND_VARIABLES			= 0x01
	$$KIND_ARRAYS					= 0x02
	$$KIND_CONSTANTS			= 0x04
	$$KIND_FUNCTIONS			= 0x07
	$$KIND_ARRAY_SYMBOLS	= 0x08
	$$KIND_SYSCONS				= 0x0C
	$$KIND_STATEMENTS			= 0x0D
	$$KIND_TYPES					= 0x10
	$$KIND_STARTS					= 0x11
	$$KIND_COMMENTS				= 0x19
	$$KIND_WHITES					= 0x1B
	$$KIND								= BITFIELD (5, 24)
	$$TYPE								= BITFIELD (5, 16)
	$$ALLO								= BITFIELD (3, 21)
'
'#endXitDbg
'
' *******************************
' *****  Xit ()  CONSTANTS  *****
' *******************************
'
	$$BP									= BITFIELD (1, 31)
	$$EXE									= BITFIELD (1, 30)
	$$BP_EXE							= BITFIELD (2, 30)
	$$CLEAR_BP						= BITFIELD (31, 0)
	$$CLEAR_BP_EXE				= BITFIELD (30, 0)
	$$CLEAR_SPACE					= BITFIELD (29, 0)
	$$NOT_LOWEST_DIM			= BITFIELD (1, 29)
	$$ELESIZE							= BITFIELD (16, 0)
'
'	***************************
'	*****  Kid Constants  *****
'	***************************
'
	$$FindCaseToggle			= 1				' XitFind kids
	$$FindLocalToggle			= 2
	$$FindReverseToggle		= 3
	$$FindFindLabel				= 4
	$$FindFindText				= 5
	$$FindReplaceLabel		= 6
	$$FindReplaceText			= 7
	$$FindRepsLabel				= 8
	$$FindRepsText				= 9
	$$FindFindButton			= 10
	$$FindReplaceButton		= 11
	$$FindCancelButton		= 12
'
'	Environment kids
'
	$$xitFileLabel				=  3
	$$xitStatusLabel			=  4
	$$xitErrorLabel				=  4
	$$xitCommand					= 34
	$$xitFunction					= 19
	$$xitTextLower				= 35
'
'	Other kids
'
	$$DialogText					= 2
	$$FileTextLine				= 2
'
	$$SourceVariables			= 1
	$$SourceArrays				= 2
	$$SourceComposites		= 3
'
' ******************************
' *****  Cursor CONSTANTS  *****			' unchanged for 1.1
' ******************************
'
	$$CursorReady					=   0
	$$CursorWarning				=  60		' Hand 2 shapeID (see cursorfont.h)
	$$CursorWait					= 150		' Watch
'
'
'#begXitDbg
'
' ************************
' *****  Core SHARED *****
' ************************
'
	SHARED  argc,  argv,  envp							' command line arguments
'
'#endXitDbg
'
'
' ************************
' *****  Xit SHARED  *****  All SHARED data objects in the Xit portion
' ************************
'
	SHARED  dispatch[7, 1]
	SHARED  dispatchCount
	SHARED  jump[25, 1]						' for jump label function number/line number
	SHARED  varTok[]
	SHARED  varSymbol$[]
	SHARED  varReg[]
	SHARED  varAddr[]
	SHARED  varDataAddr[]
	SHARED  varTypes$[]
	SHARED  reg86$[]
	SHARED  popupGrids[]
'
'	Xit Environment grids
'
	SHARED  xitWindow,  xitGrid,  xitTextLower,  xitCommand,  xitHotAbort
'
'	Xit environment popup boxes
'
	SHARED  newBox,  fileBox,  modeBox,  renameBox
	SHARED  findBox,  readBox,  writeBox,  abandonBox
	SHARED  funcBox,  viewNewBox,  deleteFuncBox,  viewRenameBox
	SHARED  viewCloneBox,  viewLoadBox,  viewSaveBox,  viewMergeBox
	SHARED  optionMiscBox,  optTabBox,  optFontBox
	SHARED  memoryBox,  assemblyBox,  registerBox
	SHARED  errorBox,  runtimeErrorBox
	SHARED  variableBox,  arrayBox,  stringBox,  compositeBox
	SHARED  framesBox
	SHARED  warning2Box,  warning3Box
'
'	Popup box SHARED variables
'
	SHARED  findText$,  replaceText$,  findReps						' findBox
	SHARED  findCase,  findLocal,  findReverse
	SHARED  tabWidth																			' optTabBox
	SHARED  regTemp[39]																		' registerBox
	SHARED  variableUp																		' variableBox
	SHARED  variableFuncRow[]
	SHARED  FRAMEINFO  variableFrame
	SHARED  arrayUp,  arrayIndex													' arrayBox
	SHARED  arrayViewIndices[7],  arrayNumViewIndices
	SHARED  stringUp,  stringSource												' stringBox
	SHARED  stringSymbol$,  stringHandle$,  stringFixed
	SHARED  compositeUp																		' compositeBox
	SHARED  compositeType,  compositeSymbol$
	SHARED  compositeHandle$,  compositeElement$
	SHARED  frameDetail																		' framesBox
	SHARED  FRAMEINFO  frameInfo[31]
	SHARED  userCursor,  userCursorOverride
'
'	Compilation error variables
'
	SHARED  uError								' UBOUND (errorArrays)
	SHARED  errorCurrent
	SHARED  errorXerror[]					' holds error info:  error code
	SHARED  errorFunc[]						' function number
	SHARED  errorRawPtr[]					' raw source line 0 offset
	SHARED  errorSrcPtr[]					' "compressed" source line pointer (offset 1)
	SHARED  errorSrcLine$[]				' "compressed" source line (no tabs)
'
'	Environment status variables
'
	SHARED  blowback												' environment blowback
	SHARED  compiledCheckBounds
	SHARED  currentCursor										' used in MainLoop
	SHARED  currentStatus
	SHARED  cursorShape
	SHARED  editFilename$
	SHARED  editFunction										' environment edit function number
	SHARED  environmentActive								' environment status
	SHARED  environmentEntered
	SHARED  exeFunction,  exeLine						' environment pointers to CURRENTEXE
	SHARED  exitMainLoop
	SHARED  fileType												' environment $$Unspecified / $$Text / $$Program / $$GuiProgram
	SHARED  graphicsInitialized
	SHARED  haltedByEdit										' environment execution halted by edit
	SHARED  lockOutEnvironment							' environment lock out after -xit
	SHARED  priorFunction
	SHARED  processingCrash									' crash in progress
	SHARED  userContinue										' environment user continued
	SHARED  userRun													' environment user run
	SHARED  userStepType										' environment continue step type
	SHARED  softInterrupt
	SHARED  textAlteredSinceLastSave
	SHARED  userGoFrame
'
'	prog[] variables
'
	SHARED  uprog
	SHARED  prog[]													' environment program array
	SHARED  programAltered									' environment prog[] altered
	SHARED  funcAltered[]
	SHARED  funcBPAltered[]
	SHARED  funcCursorPosition[]
	SHARED  funcNeedsTokenizing[]
'
'	Breakpoint variables
'
	SHARED  breakpointsAltered
	SHARED  breakAddr [63]									' breakpoint address / code arrays
	SHARED  breakCode [63]
	SHARED  breakPatchAddr [7]
	SHARED  breakPatchCode [7]
	SHARED  lineAddr [255, 15]
	SHARED  lineCode [255, 15]
	SHARED  lineLast [255]
	SHARED  lineUpper [255]
	SHARED  funcFirstAddr[255]
	SHARED  funcAfterAddr[255]
	SHARED  endProgram$[]
'
'	Memory management
'
	SHARED  codeSpaceResized
	SHARED  maxSharedMemorySize							' UCODE shared memory stats
	SHARED  maxSharedSegments
	SHARED  shmid[]													' shmid for UCODE pages
'
'	Miscellaneous
'
	SHARED  UBYTE charsetNonWhiteChar[]			' environment text->token conversion
	SHARED  defaultDirectory$								' default directory: tracks fileName
'
'
'	NT Signal handling
'
	SHARED  sigNumber
	SHARED  sigs[15]
	SHARED  EXCEPTION_RECORD   exceptionRecord
	SHARED  EXCEPTION_CONTEXT  exceptionContext
	SHARED  EXCEPTION_CONTEXT  exceptionContextOrig
'
'	header test variables
'
	SHARED  heads[]													' test header array
	SHARED  tempo[]													' test header array
	SHARED  testdibs												' header test in progress
	SHARED  teston													' header test enabled
'
'
' ********************************
' *****  COMPILER VARIABLES  *****
' ********************************
'
	SHARED  T_DECLARE
	SHARED  T_INTERNAL
	SHARED  T_EXTERNAL
	SHARED  T_FUNCTION
	SHARED  T_CFUNCTION
	SHARED  T_SFUNCTION
	SHARED  T_END
	SHARED  T_TYPE
	SHARED  T_PROGRAM
	SHARED  T_COLON
	SHARED  T_COMMENT
	SHARED  T_DIV
	SHARED  T_AUTO
	SHARED  T_AUTOX
	SHARED  T_STATIC
	SHARED  T_SHARED
	SHARED  T_VOID
	SHARED  T_SBYTE									' The data types
	SHARED  T_UBYTE
	SHARED  T_SSHORT
	SHARED  T_USHORT
	SHARED  T_SLONG
	SHARED  T_ULONG
	SHARED  T_XLONG
	SHARED  T_GIANT
	SHARED  T_SINGLE
	SHARED  T_DOUBLE
	SHARED  T_STRING
'
	EXTERNAL /xxx/  xpc
	EXTERNAL /xxx/  i486bin
	EXTERNAL /xxx/  i486asm
	EXTERNAL /xxx/  library
	EXTERNAL /xxx/  checkBounds
	EXTERNAL /xxx/  entryFunction
	EXTERNAL /xxx/  maxFuncNumber
	EXTERNAL /xxx/  errorCount
	EXTERNAL /xxx/  litStringAddr
'
'
'  ####################
'  #####  Xit ()  #####
'  ####################
'
FUNCTION  Xit (uargc, uargv, uenvp)
	SHARED  argc
	SHARED  argv$[]
	SHARED  welcome$
	SHARED	mainTitle$
	SHARED  hideWelcome
	SHARED  notifyTime$$
	SHARED  expireTime$$
	SHARED  timeExpired
	SHARED  notifyDays
	SHARED  deltaDays
	SHARED  daysLeft
'
	a$ = "Max Reason"
	a$ = "copyright 1988-2000"
	a$ = "Windows XBasic development environment"
	a$ = "maxreason@maxreason.com"
	a$ = ""
'
		' Note: Win32 is currently the only OS supported by this source.
		##XBSystem = $$XBSysWin32

' on 2000/09/01 the way ##WIN32S is computed was changed
' as a result, all ##WIN32S in this file are changed to #WINLESS as computed below
'
	#WINLESS = $$FALSE
	version = XxxGetVersion()
	platform = (version >> 16) AND 0x00FF
	IF (platform != $$VER_PLATFORM_WIN32_NT) THEN #WINLESS = $$TRUE
'
	XstGetCommandLineArguments (@argc, @argv$[])
'
	DIM h$[15]
	h$[0] = HEX$(##HINSTANCE,8)
	h$[1] = HEX$(##HINSTANCEEXE,8)
	h$[2] = HEX$(##HINSTANCEDLL,8)
	h$[3] = HEX$(##HINSTANCESTART,8)
'
	win$ = "xb.exe"
	exe$ = "xb.exe"
	dll$ = "xb.dll"
'
	IF argv$[] THEN
		pro$ = argv$[0]
		IF pro$ THEN
			u = UBOUND (pro$)
			h$[4] = ":" +  pro$ +  ":"
			IF (pro${0} = '"') THEN
				IF (pro${u} = '"') THEN
					pro$ = MID$(pro$,2,u-1)
				END IF
			END IF
			h$[5] = "'" +  pro$ + "'"
			dot = RINSTR (pro$, ".")
			IF dot THEN pro$ = LEFT$(pro$,dot-1)
			h$[6] = pro$
			win$ = pro$								' command line without ".exe"
			exe$ = pro$ + ".exe"			' command line + ".exe"
			dll$ = pro$ + ".dll"			' command line + ".dll"
		END IF
	END IF
	h$[7] = pro$
'
	win = GetModuleHandleA (&win$)	' hInstance of "xb"
	exe = GetModuleHandleA (&exe$)	' hInstance of "xb.exe"
	dll = GetModuleHandleA (&dll$)	' hInstance of "xb.dll"
'
	##HINSTANCEEXE = exe		' hInstance of xb.exe
	##HINSTANCEDLL = dll		' hInstance of xb.dll
	IFZ ##HINSTANCE THEN ##HINSTANCE = ##HINSTANCEEXE
	IFZ ##HINSTANCE THEN ##HINSTANCE = ##HINSTANCEDLL
'
	h$[ 9] = "win = '" + win$ + "' : " + HEX$(win, 8)
	h$[10] = "exe = '" + exe$ + "' : " + HEX$(exe, 8)
	h$[11] = "dll = '" + dll$ + "' : " + HEX$(dll, 8)
	h$[12] = "##HINSTANCE = " + HEX$(##HINSTANCE, 8)
	h$[13] = "##HINSTANCEEXE = " + HEX$(##HINSTANCEEXE, 8)
	h$[14] = "##HINSTANCEDLL = " + HEX$(##HINSTANCEDLL, 8)
	h$[15] = "##HINSTANCESTART = " + HEX$(##HINSTANCESTART, 8)
'
	argu = argc-1
	upper = UBOUND (argv$[])
	IF (argu < upper) THEN upper = argu
'
	FOR i = 0 TO upper
		IF (argv$[i] = "-hinst") THEN
			XstSaveStringArray ("hinst.txt", @h$[])
			EXIT FOR
		END IF
	NEXT i
'
	Xst ()
	XutPDEInit()
	Xio()
	XutInit()
  ' Note that Xin() must initialized in the PDE, even if it's not used.
	' Otherwise it's shared variables can be initialized in 'user mode' which
	' causes all kinds of horrors if it *is* used.
	Xin ()
	Xma ()
	Xcm ()
	Xgr ()
	Xui ()
	Xnt ()
	Xdis ()
'
	InitGui ()
	InitProgram ()
	hideWelcome = $$FALSE
'
	remains = Welcome ()
	XstLoadString (@"$XBDIR/templates/name.xxx", @name$)
	XstLoadString (@"$XBDIR/templates/intro.xxx", @intro$)
	XstLoadString (@"$XBDIR/templates/start.xxx", @start$)
	XstLoadString (@"$XBDIR/templates/title.xxx", @title$)
	XstLoadString (@"$XBDIR/templates/expire.xxx", @expire$)
	mainTitle$ = title$
'
' 1st notify : 0x80000000 and notifyTime$$ == 0 and expireTime$$ == 0
' 2nd notify : 0x80000000 and notifyTime$$ != 0 and expireTime$$ == 0
' 3rd notify : 0x80000000 and notifyTime$$ != 0 and expireTime$$ != 0
'
	SELECT CASE TRUE
		CASE (remains = 0x80000000)
					hideWelcome = $$FALSE
					IF (daysLeft < 0) THEN
						remains = ABS (daysLeft)
						past$ = STRING$(remains) + " days ago"
					END IF
					welcome$ = "thanks for trying\n" + name$ + "\n\nyour trial expired " + past$
					IF notifyTime$$ THEN
						IF expireTime$$ THEN
							timeExpired = $$TRUE
						END IF
					END IF
					IFZ timeExpired THEN welcome$ = welcome$ + "\n!!! final courtesy session !!!"
					IF expire$ THEN welcome$ = welcome$ + "\n\n" + expire$
		CASE (remains < 0)
					hideWelcome = $$TRUE
					IF name$ THEN name$ = "\nTo\n" + name$
					welcome$ = "Welcome" + name$ + "\n\nInitializing\nPlease Wait"
					PRINT "initialization authority error ::: "; remains;; daysLeft;; deltaDays
		CASE (remains > 0)
					remains = remains - 1
					IF (remains <= notifyDays) THEN
						hideWelcome = $$FALSE
						IF name$ THEN name$ = "\nTo\n" + name$
						welcome$ = "welcome" + name$ + "\n\nyou have\n" + STRING$(remains) + " days left"
						IF intro$ THEN welcome$ = welcome$ + "\n\n" + intro$
					ELSE
						IF start$ THEN
							welcome$ = start$
							hideWelcome = $$FALSE
						ELSE
							hideWelcome = $$TRUE
							IF name$ THEN name$ = "\nTo\n" + name$
							welcome$ = "welcome" + name$ + "\n\ninitializing\nplease wait"
						END IF
					END IF
		CASE (remains = 0)
					IF start$ THEN
						welcome$ = start$
						hideWelcome = $$FALSE
					ELSE
						hideWelcome = $$TRUE
						welcome$ = "initializing\n" + name$ + "\n\nplease wait"
					END IF
	END SELECT
'
	name$ = ""
	intro$ = ""
	title$ = ""
	expire$ = ""
	message$ = ""
'
' establish backslash array for text-line input
'
	upper = 255
	DIM #backslash[upper]
'
	FOR i = 0 TO upper
		SELECT CASE TRUE
			CASE (i == 0x09)	: #backslash[i] = 1					' no backslash \t tab character
			CASE (i == 0x0A)	: #backslash[i] = 1					' no backslash \n newline character
			CASE (i == 0x0D)	: #backslash[i] = 1					' no backslash \r return character
			CASE (i <= 0x1F)	: #backslash[i] = 1					' do backslash other control characters
			CASE (i == 0x22)	: #backslash[i] = 1					' do backslash "" double-quote characters
			CASE (i == 0x5C)	: #backslash[i] = 1					' do backslash \\ backslash characters
			CASE (i <= 0x7F)	: #backslash[i] = 0					' display all English characters
			CASE (i >= 0x80)	: #backslash[i] = 0					' display non-English characters
		END SELECT
	NEXT i
'
	XitBlowback ()
	XitQuit (0)											' not designed to return here
END FUNCTION
'
'
'  #####################
'  #####  XitMain  #####  Invoked on program startup and all SIGNALs
'  #####################  (bus error, math errors, break key, etc.)
'
FUNCTION  XitMain (signalCode, signalInfo)
	EXTERNAL  /xxx/  checkBounds,  library
	SHARED  teston
	SHARED  argc
	SHARED  argv$[]
	SHARED  fileType
	SHARED  welcome$
	SHARED  hideWelcome
	SHARED  romanFont
	SHARED  messageFont
	SHARED  courierFont
	SHARED  welcomeFont
	SHARED  verdanaFont
	SHARED	comicFont
	SHARED  labelFont
	SHARED	buttonFont
	SHARED  comicBigFont
	SHARED  environmentActive
	SHARED  environmentEntered
	SHARED  userContinue
	SHARED  userStepType
	SHARED  userRun
	SHARED  editFunction
	SHARED  sigNumber
	SHARED  breakAddr[]
	SHARED  breakCode[]
	SHARED  lineAddr[],  lineLast[],  funcAfterAddr[]
	SHARED  xitGrid
	SHARED  blowback
	SHARED  haltedByEdit
	SHARED  programAltered
	SHARED  exeFunction, exeLine				' pointers to CURRENTEXE
	SHARED  funcBPAltered[],  funcNeedsTokenizing[]
	SHARED  processingCrash
	SHARED  lockOutEnvironment
	SHARED  EXCEPTION_RECORD   exceptionRecord
	SHARED  EXCEPTION_CONTEXT  exceptionContext
	SHARED  EXCEPTION_CONTEXT  exceptionContextOrig
	SHARED  userCursor,  userCursorOverride
	STATIC  args$[],  fpEnv[]
	STATIC  notFirstEntry
	STATIC  signalEntry
	STATIC  poppingFrames
	STATIC  ebpStart
	STATIC  espStart
	STATIC  entry
	STATIC  huh
'
	entrySIGNALACTIVE = ##SIGNALACTIVE
	entryWHOMASK = ##WHOMASK
	##WHOMASK = 0
'
	IFZ entry THEN
		entry = $$TRUE
		XxxGetEbpEsp (@ebpStart, @espStart)
		IF huh THEN PRINT "XxxXitMain() : ebpStart espStart = "; HEX$(ebpStart,8);; HEX$(espStart)
	END IF
'
	XstSystemExceptionToException (signalCode, @exception)
	##OSEXCEPTION = signalCode
	##EXCEPTION = exception
'
	IF huh THEN
		XstExceptionNumberToName (exception, @exception$)
		PRINT "XxxXitMain() :  signal  exception   whomask    exception$          signalEntry"
		PRINT "####======>> : "; HEX$(signal,8);;; HEX$(exception,8);;; HEX$(whomask,8);;; exception$;;; signalEntry
	END IF
'
'	If environmentEntered, SIGINT only valid when ##USERRUNNING and
'		not paused (not signalEntry)
'		(If no environment, allow the break as the only means to enter debugger)
'
	IF huh THEN PRINT "a";
	IF signalCode THEN
		IF huh THEN PRINT "b";
'
'		If FP exception, FPU is NOT cleared.  Must do this manually.
'			Must be done immediately, before any use of FPU (eg PRINTing to the
'				Console uses FP ops on the scrollbars).
'			Assume it is OK to clear the FPU on non-FP exceptions because upon return
'				the FPU state is reloaded from the signalInfo structure.
'				(7/2/93)
'
		XxxClearFPException ()
		##SIGNALACTIVE = $$TRUE
'
		XstSystemExceptionToException (signalCode, @sigNumber)
		IF ((sigNumber = 0) OR (sigNumber = $$ExceptionUnknown)) THEN
'			PRINT "XitMain can't handle signal: "; HEXX$(signalCode,8), HEXX$(signalInfo,8)
'			addrExceptionRecord = XLONGAT (signalInfo, [0])
'			exceptionAddress = XLONGAT (addrExceptionRecord, [3])
'			PRINT "  er, eip = "; HEXX$(addrExceptionRecord,8), HEXX$(exceptionAddress,8)
'			Sleep (3000)
'			INLINE$ ("  Press return:")
			##SIGNALACTIVE = entrySIGNALACTIVE
			##WHOMASK = entryWHOMASK
			IF huh THEN PRINT "d"
			RETURN ($$EXCEPTION_CONTINUE_SEARCH)			' can't handle this
		END IF
'
'		XstExceptionNumberToName (sigNumber, @signal$)
'		PRINT "XitMain() signalCode,sigNumber,signal$ = "; HEX$(signalCode,8), HEX$(sigNumber,8), signal$
'
		GOSUB GetExceptionInfo
'
'		PRINT "USERRUNNING, SIGACTIVE, WHOMASK = "; ##USERRUNNING, entrySIGNALACTIVE, HEX$(entryWHOMASK,8)
'		PRINT "exceptionContext.contextFlags   = "; HEX$(exceptionContext.contextFlags,8)
'		PRINT "exceptionContext.eip            = "; HEX$(exceptionContext.eip,8)
'		PRINT "exceptionContext.ebp            = "; HEX$(exceptionContext.ebp,8)
'		PRINT "exceptionContext.esp            = "; HEX$(exceptionContext.esp,8)
'
'		INLINE$("Press Return:")
'
'		fp$ = "\nFloating point signalInfo:"
'		fp$ = fp$ + "\n  control word = " + HEX$(exceptionContext.floatSave.controlWord, 8)
'		fp$ = fp$ + "\n  status word  = " + HEX$(exceptionContext.floatSave.statusWord, 8)
'		fp$ = fp$ + "\n  tag word     = " + HEX$(exceptionContext.floatSave.tagWord, 8)
'		fp$ = fp$ + "\n  errorOffset  = " + HEX$(exceptionContext.floatSave.errorOffset, 8)
'		fp$ = fp$ + "\n  errorSelect  = " + HEX$(exceptionContext.floatSave.errorSelector, 8)
'		fp$ = fp$ + "\n  dataOffset   = " + HEX$(exceptionContext.floatSave.dataOffset, 8)
'		fp$ = fp$ + "\n  dataSelector = " + HEX$(exceptionContext.floatSave.dataSelector, 8)
'		fp$ = fp$ + "\n  cr0NpxState  = " + HEX$(exceptionContext.floatSave.cr0NpxState, 8)
'		PRINT fp$
'
		IF (sigNumber = $$ExceptionStackOverflow) THEN
			IFZ poppingFrames THEN
				GOSUB GetExceptionInfo
				poppingFrames = $$TRUE
				##SIGNALACTIVE = entrySIGNALACTIVE
				##WHOMASK = entryWHOMASK
				Pop16Frames (signalCode, signalInfo)					' Still a bit messy
			END IF
			poppingFrames = $$FALSE
		END IF
'
		IF (sigNumber = $$ExceptionBreakKey) THEN
			IF environmentEntered THEN
				IF ((NOT ##USERRUNNING) || signalEntry) THEN	' nothing to interrupt
					##SIGNALACTIVE = entrySIGNALACTIVE
					##WHOMASK = entryWHOMASK
					IF huh THEN PRINT "e"
					RETURN ($$EXCEPTION_CONTINUE_EXECUTION)			' or already interrupted
				END IF
			END IF
		END IF
	END IF
'
' If ##USERRUNNING, $$ExceptionBreakKey is a softBreak
'
	IF (sigNumber = $$ExceptionBreakKey) THEN
		IF huh THEN PRINT "f"
		XitSoftBreak ()
		##SIGNALACTIVE = entrySIGNALACTIVE
		##WHOMASK = entryWHOMASK
		RETURN ($$EXCEPTION_CONTINUE_EXECUTION)
	END IF
'
'	Make a COPY of signalInfo
'
	IF signalInfo THEN
		GOSUB GetExceptionInfo
		sxip = exceptionRecord.exceptionAddress			' "sxip" = addr (from 88k)
'
'		Win32s uses Illegal 2-byte instruction for breakpoint (0xF00F)
'
		IF #WINLESS THEN
			IF (sigNumber = $$ExceptionInvalidInstruction) THEN
'				PRINT "SIGILL:  Checking for F00F at "; HEX$(sxip,8)
'				IF (USHORTAT(sxip) = 0x0F0F) THEN sigNumber = $$ExceptionBreakpoint
				IF (USHORTAT(sxip) = $$BREAK2) THEN sigNumber = $$ExceptionBreakpoint
			END IF
		END IF
'
'		Adjust .eip if RuntimeError
'
		IF huh THEN PRINT "g";
		labels = XxxGetLabelGivenAddress (sxip, @labels$[])
		IF (labels > 0) THEN
			FOR i = 0 TO labels-1
'				SELECT CASE labels$[i]									' busted
				SWAP labels$[i], label$
				SELECT CASE label$
					CASE "_XxxRuntimeError", "_XxxRuntimeError2"
						esp		= exceptionContext.esp				' pop return address
						sxip	= XLONGAT(esp)
						exceptionContext.esp = esp + 4
						exceptionContext.eip = sxip
						exceptionRecord.exceptionAddress = sxip
						IF huh THEN PRINT "h";
						EXIT FOR
				END SELECT
			NEXT i
		END IF
'		IF (sxip != exceptionContext.eip) THEN
'			PRINT "XitMain() : exceptionAddress != eip  "; HEX$(sxip,8), HEX$(exceptionContext.eip,8)
'		END IF
'		PRINT "Signal Address = "; HEX$(sxip,8); ":  "; XxxDisassemble$(sxip, $$TRUE)
'		IF (sigNumber = $$ExceptionInvalidInstruction) THEN
'			PRINT Dump$(HEX$(sxip AND 0xFFFFFFE0,8), "")
'		END IF
	END IF
'
	IF huh THEN PRINT "i";
	reEntry = sigNumber
'
'	Check for FATAL SIGNAL:
'		This is any signal (other than SIGINT):
'			- occuring during another signal (usually Segment Violation)
'		  - occuring when user code is not running
'		Or SIGQUIT (when ##USERRUNNING):                        ' WindowsNT
'			- where  ##BEGINALLOCODE <= SXIP <= ##ENDALLOCODE
'					(allocation area will be corrupted)
'
'		It reflects a fatal error in the environment code.  The text/program is
'			immediately (automatically) saved in a temp file and the programmer is
'			warned to exit immediately.  Exit is not forced so I or the programmer
'			can examine memory and discover the source of the error.
'
'		This may need to be adjusted if we implement a user clock...
'
	IF (sigNumber AND (sigNumber != $$ExceptionBreakKey)) THEN
		fatal = $$FALSE
		SELECT CASE TRUE
			CASE (reEntry && signalEntry):					fatal = $$FatalSignalInEnv
						IF huh THEN PRINT "j";
			CASE (reEntry && (NOT ##USERRUNNING)):	fatal = $$FatalSignalInEnv
						IF huh THEN PRINT "k";
			CASE (sigNumber = $$ExceptionBreakKey)
						IF huh THEN PRINT "l";
				IF (##BEGINALLOCODE <= sxip) AND (sxip <= ##ENDALLOCODE) THEN
					fatal = $$FatalSigQuitInAllo
					IF huh THEN PRINT "m";
				END IF
		END SELECT
'
		IF fatal THEN
			IF huh THEN PRINT "n";
			PRINT reEntry, signalEntry, ##USERRUNNING, whomask, eip, exception$
			PRINT HEX$(reEntry) + "  " + HEX$(signalEntry) + "  " + HEX$(##USERRUNNING) + "  " + HEX$(whomask,8) + "  " + HEX$(eip,8) + "  " + exception$
			IFZ processingCrash THEN
				IF huh THEN PRINT "o";
				XitCrash (sigNumber, sxip, fatal)
			ELSE
				IF huh THEN PRINT "p";
				PRINT "***  Fatal error during Crash Processing:  Bye.  ***"
				INLINE$ ("  Press enter to terminate...")
				XitQuit (1)
			END IF
		END IF
	END IF
	signalEntry = reEntry
'
' SOFTBREAK is set if ##USERRUNNING and Break key struck.
'		This sets traps in user code and continues, thus a trap halts the code.
'		SOFTBREAK is used to break SYSTEMCALLs.  Once XitMain is entered, the
'			SOFTBREAK flag is no longer required.
'
	##SOFTBREAK = $$FALSE											' reset softBreak
'
	IFZ notFirstEntry THEN DIM args$[15]
'
'	MakeUserCodeRW ()													' NT:  Not required
'
	IF huh THEN PRINT "q";
	IF signalEntry THEN
		IF huh THEN PRINT "r";
		topLevel = $$FALSE
		breakPatches = BreakPatch ()						' Remove the patch breakpoints
'		PRINT "breakPatches = "; breakPatches, exception
		IF (sigNumber = $$ExceptionBreakpoint) THEN
'			BreakPatch purpose is to break after 1 machine instruction and continue
'				So if one exists, bop on back...
			IF huh THEN PRINT "s";
			IF breakPatches THEN									' reexecute this address
'				PRINT "breakPatches:  breakAddr = "; HEX$(sxip, 8)
'				NT restarts at current address (VERIFY!)
'				MakeUserCodeRX ()										' NT:  Not required
'				PRINT "XitMain() : continue after invisible patch at "; HEX$(sxip, 8)
				IF huh THEN PRINT "t"
				signalEntry = $$FALSE
				sigNumber = 0
				##SIGNALACTIVE = entrySIGNALACTIVE
				##WHOMASK = entryWHOMASK
				RETURN ($$EXCEPTION_CONTINUE_EXECUTION)
			END IF
		END IF
		IFZ programAltered THEN BreakInternal ($$BreakRemoveAll, 0, 0, 0)
'
		IF huh THEN PRINT "u";
		IF (fileType = $$Program) THEN
			IF huh THEN PRINT "v";
			RemoveExeLinePtr ()													' reset exeFunction/exeLine
			IF environmentEntered THEN
				IF huh THEN PRINT "w";
				IFZ haltedByEdit THEN UpdateFrames ()			' set exeFunction/exeLine
			ELSE
				IF huh THEN PRINT "x";
				GetFuncAndLineNumberAtThisAddress (sxip)
			END IF
			IF exeFunction THEN
				IF huh THEN PRINT "y";
'				PRINT "found breakpoint on line"; exeLine; " of func"; exeFunction
				IF environmentActive THEN
					IFZ haltedByEdit THEN
						Display (exeFunction, exeLine, 0, -1, -1)		' Change to exeFunction
					END IF
					SetExeLinePtr ()
'					Message (" found breakpoint on line " + STRING$(exeLine) + " of func " + STRING$(exeFunction) + " ")
					AddCommandItem ("found breakpoint on line " + STRING$(exeLine) + " of func " + STRING$(exeFunction))
					IF huh THEN PRINT "z";
				END IF
			ELSE
				IFZ haltedByEdit THEN
					Message (" can't find line at breakpoint address " + HEX$(sxip, 8) + " ")
'					AddCommandItem (" can't find line at breakpoint address " + HEX$(sxip, 8) + " ")
				END IF
			END IF
			IF environmentEntered THEN
				SetDataDisplays ()
				XxxXgrReleaseMice ()
			END IF
		END IF
'
		XgrSetCursor (0, @userCursor)
		XgrSetCursorOverride (0, @userCursorOverride)
		UpdateRuntimeError ()
	ELSE
		IF huh THEN PRINT "0";
		topLevel = $$TRUE
		IFZ notFirstEntry THEN
			IF huh THEN PRINT "1";
			IF (argc > 1) THEN
				IF huh THEN PRINT "2";
				library			= $$FALSE
				checkBounds	= $$FALSE
				start = 1
'
				commandCompile = $$FALSE							' command line compilation?
				IF (argv$[1]{0} != '-') THEN
					commandCompile = $$TRUE							' filename is argv$[1]
					INC start
				END IF
'
'				Look for command line switches
'
				FOR i = start TO (argc - 1)
					a$ = LCASE$(TRIM$(argv$[i]))
					IFZ a$ THEN EXIT FOR								' done with switches
					IF (a${0} != '-') THEN DO NEXT
'
					SELECT CASE TRUE
						CASE (a$ = "-version"), (a$ = "-versions"), (a$ = "-ver")
							PRINT
							PRINT "Versions:"
							PRINT "  Compiler     "; XxxXBasicVersion$ ()
							PRINT "  Environment  "; XitVersion$ ()
							PRINT "  Libraries:"
							PRINT "    Xcm        "; XcmVersion$ ()
							PRINT "    Xgr        "; XgrVersion$ ()
							PRINT "    Xma        "; XmaVersion$ ()
							PRINT "    Xst        "; XstVersion$ ()
							PRINT "    Xui        "; XuiVersion$ ()
							PRINT
							INLINE$ ("Press RETURN: ")
							XitQuit (0)
						CASE (a$ = "-lib"), (a$ = "-library")
							library = $$TRUE
						CASE (a$ = "-bc")
							checkBounds = $$TRUE
						CASE (a$ = "-xit")
							doXit = $$TRUE
							EXIT FOR
						CASE (a$ = "-h"), (a$ = "-help"), (a$ = "?")
							PRINT
							PRINT "Usage:"
							PRINT "  xb                        - enter program development environment"
							PRINT "  xb filename [switches]    - command line compilation"
							PRINT "     -bc                    - bounds checking on"
							PRINT "     -lib                   - compile as a library"
							PRINT "  xb -version               - display versions of components"
							PRINT "  xb -xit                   - enter primitive debugger"
							PRINT "  xb -h                     - this help message"
							PRINT
							INLINE$ ("Press RETURN: ")
							XitQuit (0)
					END SELECT
				NEXT i
'
				IF commandCompile THEN										' command line compilation
					EnableAbortSignals ()
					Go ()
					XitQuit (0)
				END IF
			END IF
'
			checkBounds = $$TRUE												' environment default checkBounds
			IF doXit THEN
				PrintMenu ()
			ELSE
				IF huh THEN PRINT "3";
				IFZ environmentEntered THEN
					IF huh THEN PRINT "4";
'					IFZ welcomeFont THEN
						SELECT CASE TRUE
							CASE welcomeFont	: welcomeFont = welcomeFont
							CASE comicFont		: welcomeFont = comicFont
							CASE comicBigFont	: welcomeFont = comicBigFont
							CASE verdanaFont	: welcomeFont = verdanaFont
							CASE messageFont	: welcomeFont = messageFont
							CASE romanFont		: welcomeFont = romanFont
							CASE courierFont	: welcomeFont = courierFont
							CASE ELSE					: welcomeFont = 0
						END SELECT
'					END IF
'
					update = $$FALSE
'
					IFZ ini$[] THEN
						filename$ = "c:/windows/xb.ini"
						XstLoadStringArray (@filename$, @ini$[])
					END IF
'
' "about=false" and "about=0" mean "never display the startup window"
' "about=true" and "about=-1" mean "always display the startup window"
'
					IFZ ini$[] THEN
						DIM ini$[1]
						ini$[0] = "xin=false"
						ini$[1] = "about=1"
						filename$ = "c:/windows/xb.ini"
						update = $$TRUE
					ELSE
						upper = UBOUND (ini$[])
						FOR i = 0 TO upper
							ini$ = ini$[i]
							IF ini$ THEN
								IF (ini${0} != ''') THEN
									about = INSTR (ini$, "about")
									IF about THEN
										equal = INSTR (ini$, "=", about+1)
										IFZ equal THEN
											about = $$FALSE
										ELSE
											times$ = TRIM$(MID$(ini$, equal+1))
											SELECT CASE times$
												CASE "false"	: times = 0
												CASE "true"		: times = -1
												CASE ELSE			: times = SLONG (times$)
											END SELECT
											ini$ = LEFT$ (ini$, equal)
'											PRINT "<"; times$; ">"
'											PRINT "<"; times; ">"
											SELECT CASE TRUE
												CASE (times == 0)	: display = $$FALSE	: update = $$FALSE	: add = 0
												CASE (times <  0)	: display = $$TRUE	: update = $$FALSE	: add = 0
												CASE (times <  4)	: display = $$TRUE	: update = $$TRUE		: add = 1
												CASE ELSE					: display = $$FALSE	: update = $$TRUE		: add = 1
																						IFZ (times AND 0x000F) THEN display = $$TRUE
											END SELECT
											times = times + add
											times$ = STRING$ (times)
											ini$ = ini$ + times$
											ini$[i] = ini$
											EXIT FOR
										END IF
									END IF
								END IF
							END IF
						NEXT i
						IFZ about THEN
							IF ini$[upper] THEN
								INC upper
								times = 0
								REDIM ini$[upper]
							END IF
							ini$[upper] = "about=1"
							display = $$TRUE
							update = $$TRUE
						END IF
					END IF
'					PRINT "<"; times$; ">"
'					PRINT "<"; times; ">"
'
					IF update THEN XstSaveStringArray (@filename$, @ini$[])
					HelpAbout (display)
'
' why the following is needed to stop some main window icons from
' appearing black and without images is totally beyond my feeble mind
'
					FOR sleep = 0 TO 100
						XgrProcessMessages (0)
					NEXT
					XstSleep (250)
					FOR sleep = 0 TO 100
						XgrProcessMessages (0)
					NEXT
'
					failed = CreateWindows ()
					IF hideWelcome THEN XuiSendMessage ( welcomeGrid, #HideWindow, 0, 0, 0, 0, 0, 0)
					XgrProcessMessages (-2)
					IF failed THEN
						PRINT "Cannot start environment:  Windows is not running"
						INLINE$ ("  Press RETURN: ")
						XitQuit (0)
					ELSE
						IF huh THEN PRINT "5";
						environmentActive = $$TRUE
						InitWindows()
					END IF
				END IF
			END IF
		END IF
'
		IF environmentActive THEN
			ResetDataDisplays ($$ResetAssembly)				' may be new line
		END IF
	END IF	' signalEntry
	notFirstEntry = $$TRUE
	haltedByEdit = $$FALSE
'
	IF huh THEN PRINT "A";
	DO
		IF huh THEN PRINT "B";
		IF environmentActive THEN
			IF huh THEN PRINT "C";
			IF blowback THEN
				IF huh THEN PRINT "D";
				command$	= ""		' Free local allocation
				a$				= ""		'	missing:  SELECT CASE command$ internal string
				arg0$			= ""
				arg1$			= ""
				arg2$			= ""
				arg3$			= ""
				arg4$			= ""
				arg5$			= ""
				arg6$			= ""
'
				IF huh THEN PRINT "E";
				IF sigNumber THEN
					IF huh THEN PRINT "F"
					exceptionContext.eip = &XitBlowback()
'					PRINT "Setting eip to XitBlowback()  WHOMASK = ", HEX$(##WHOMASK,8) , HEX$(entryWHOMASK,8)
					GOSUB SetExceptionInfo
					sigNumber = 0
					##SIGNALACTIVE = $$FALSE
					##WHOMASK = entryWHOMASK
					RETURN ($$EXCEPTION_CONTINUE_EXECUTION)
				ELSE
					IF huh THEN PRINT "G";
					XitBlowback ()
				END IF
			END IF
'
			IF huh THEN PRINT "H";
			IF userContinue THEN
				IF huh THEN PRINT "I";
				userContinue = $$FALSE
				IF (fileType != $$Program) THEN
					Message (" can't continue \n\n not in PROGRAM mode ")
					DO DO
				END IF
				IFZ ##USERRUNNING THEN
					Message (" program not running ")
					DO DO
				END IF
				IF programAltered THEN
					Message (" program altered \n\n cannot continue ")
					DO DO
				END IF
				SELECT CASE userStepType
					CASE  $$BreakContinueToCursor
						IF huh THEN PRINT "J";
						continueCommand = $$BreakContinueToCursor
						func = editFunction
						IFZ func
							Message (" HotToCursor \n\n invalid in PROLOG ")
							DO DO
						END IF
					CASE  $$BreakContinueStepLocal
						IF huh THEN PRINT "K";
						continueCommand = $$BreakContinueStepLocal
						func = editFunction
						IFZ func
							Message (" StepLocal \n\n invalid in PROLOG ")
							DO DO
						END IF
					CASE  $$BreakContinueStepGlobal
						IF huh THEN PRINT "L";
						continueCommand = $$BreakContinueStepGlobal
					CASE  ELSE
						IF huh THEN PRINT "M";
						continueCommand = $$BreakContinueRunning
				END SELECT
				userStepType = $$BreakContinueRunning
				IF huh THEN PRINT "N";
				GOSUB UserContinue
				IF huh THEN PRINT "O";
				DO DO
			END IF
'
			IF huh THEN PRINT "P";
			IF userRun THEN
				IF huh THEN PRINT "Q";
				IF (fileType != $$Program) THEN
					Message (" can't run \n\n not in program mode ")
					IF huh THEN PRINT "R";
					DO DO
				END IF
				IF huh THEN PRINT "S";
				userRun = $$FALSE
				compilationError = CompileProgram ()
				IF compilationError THEN
					ResetDataDisplays ($$ResetAssembly)			' still altered..
					IF huh THEN PRINT "T";
					DO DO
				END IF
				IF huh THEN PRINT "U";
				SELECT CASE userStepType
					func = editFunction
					CASE $$BreakContinueToCursor
								IF huh THEN PRINT "V";
								XuiSendMessage (xitGrid, #GetTextCursor, 0, @line, 0, 0, $$xitTextLower, 0)
								BreakInternal ($$BreakInstallOne, func, line, 0)
					CASE $$BreakContinueStepLocal
								IF huh THEN PRINT "W";
								BreakInternal ($$BreakInstallFunc, func, 0, 0)
					CASE $$BreakContinueStepGlobal
								IF huh THEN PRINT "X";
								BreakInternal ($$BreakInstallAll, 0, 0, 0)
				END SELECT
				userStepType = $$BreakContinueRunning
				IF huh THEN PRINT "Y";
				GOSUB UserGo
				IF huh THEN PRINT "Z";
				DO DO
			END IF
			IF huh THEN PRINT ":"
			XitExecute ()
			IF huh THEN PRINT "."
			DO DO
		END IF	' environment loop
'
		IF huh THEN PRINT "*";
		EnableAbortSignals ()
		IF environmentEntered THEN SetCurrentStatus ($$StatusXit, 0)
'
		a$ = INLINE$("> command:  ")
		command$ = ParseLine$(a$, @args$[])
		IFZ command$ THEN
			PrintMenu ()
			DO DO
		END IF
		firstChar = command${0}
		arg0$ = args$[0]
		arg1$ = args$[1]:  arg1 = XLONG("0x" + arg1$)
		arg2$ = args$[2]:  arg2 = XLONG("0x" + arg2$)
		arg3$ = args$[3]:  arg3 = XLONG("0x" + arg3$)
		arg4$ = args$[4]:  arg4 = XLONG("0x" + arg4$)
		arg5$ = args$[5]:  arg5 = XLONG("0x" + arg5$)
		arg6$ = args$[6]:  arg6 = XLONG("0x" + arg6$)
'
		SELECT CASE firstChar											' secondChar at least a NULL
			CASE 'r':	secondChar = command${1}
								IF ((secondChar >= '0') AND (secondChar <= '9')) THEN
'									ChangeRegister (@##REG[], arg0$, arg1$)
									DO LOOP
								END IF
			CASE 'x':	secondChar = command${1}
								IF ((secondChar >= '0') AND (secondChar <= '9')) THEN
'									ChangeRegister (@##SYSREG[], arg0$, arg1$)
									DO LOOP
								END IF
		END SELECT
		SELECT CASE  command$
			CASE "hu":  huh = NOT huh
			CASE "xm":  IFZ lockOutEnvironment THEN
										XitExecute ()
									ELSE
										PRINT "Cannot enter environment after  xit> go"
									END IF
			CASE "go":  PRINT "\nq  Returns to xit menu"
									library = $$FALSE
									Go ()														' go Execute program
			CASE "q" :  XitQuit (0)											' quit PDE

			CASE "r" :  DisplayRegisters ()							' display user registers
			CASE "m" :  PRINT MemoryMap$ ()							' display memory map
			CASE "d" :  PRINT Dump$ (arg1$, arg2$)			' dump specified memory
			CASE "cd":  PRINT Dump$ (HEX$(##DYNO),"0100")	' dump 1st 0x0100 of dynos
			CASE "t" :  PRINT Dump$ (HEX$(##DATA),"0100")	' dump dyno table, etc...
			CASE "a" :  PRINT XxxAsm$ (arg1, arg2)			' assembly code disassembly
			CASE "f" :  Fill (arg1$, arg2$, arg3$)			' fill memory
			CASE "fr":  PRINT Frames$ ()								' Frames
			CASE "l" :  PRINT Locate$ (arg1$)						' locate word in memory
			CASE "s" :  Substitute (arg1)								' substitute into memory
			CASE "h" :  Headers (##DATA, ##DYNO)				' display dyno headers
			CASE "ch":  CountHeaders ()
			CASE "th":  IF teston THEN
										PRINT "Testing headers..."
										TestHeaders ()								' test dyno headers
									ELSE
										PRINT "Use 'to' to enable 'th'."
									END IF
			CASE "to":  teston = NOT teston							'   catcher
									IFZ teston THEN PRINT "Testing OFF" ELSE PRINT "Testing ON"
			CASE "b" :  BreakProgrammer ($$BreakSetOne, arg1, 0)
			CASE "u" :  BreakProgrammer ($$BreakClearOne, arg1, 0)
			CASE "uu":  BreakProgrammer ($$BreakClearAll, 0, 0)
			CASE "g" :  GOSUB UserGo										' start user program
			CASE "c" :  continueCommand = $$BreakContinueRunning
									GOSUB UserContinue							' continue user program
			CASE "sl":  continueCommand = $$BreakContinueStepLocal
									func = editFunction
									GOSUB UserContinue
			CASE "sg":  continueCommand = $$BreakContinueStepGlobal
									GOSUB UserContinue
			CASE ELSE:  PrintMenu ()										' unknown command
		END SELECT
	LOOP
'
	IF huh THEN PRINT "#"
	sigNumber = 0
	##SIGNALACTIVE = entrySIGNALACTIVE
	##WHOMASK = entryWHOMASK
	RETURN ($$EXCEPTION_EXECUTE_HANDLER)
'
' *****  UserGo  *****
'
SUB UserGo
	UserGo ()
END SUB
'
' *****  UserContinue  *****
'
'		Conditions:  (Consider changes in future versions)
'			* Can only continue if signal occured in USER code space
'					RuntimeError routine has been altered (see XitMain() top)
'						so that entryAddress APPEARS to be from calling function.
'						If RuntimeError was generated by library, etc: no continue.
'			* If .eip has been altered (eg RunJump), it must be within current
'					function, and reset to beginning of source line containing that
'					address.
'			* If .eip wasn't altered, then reset .eip at beginning of current
'					source line.
'
SUB UserContinue																		' program not altered
	IF topLevel THEN EXIT SUB
'
	entryAddress = exceptionRecord.exceptionAddress
	addr = AddressOk(entryAddress)
'
	IF (addr != ##UCODEZ) THEN
		a$ = " can't resume execution\n\n address not in user code space \n\n" + HEXX$(entryAddress,8) + " "
		Message (@a$)
		EXIT SUB
	END IF
'
'	Continue at beginning of line containing .eip
'
	newSXIP = exceptionContext.eip
	IF ((exeFunction <= 0) OR (exeFunction > UBOUND(lineAddr[]))) THEN
		Message (" RunContinue \n\n internal error \n\n invalid exeFunction \n\n" + STRING$(exeFunction) + " ")
		EXIT SUB
	END IF
	lineLast = lineLast[exeFunction]
	IF (newSXIP < lineAddr[exeFunction,0]) THEN GOTO InvalidReturnAddr
	IF lineLast THEN
		FOR line = 1 TO lineLast
			IF (newSXIP < lineAddr[exeFunction,line]) THEN
				DEC line
				EXIT FOR
			END IF
		NEXT line
		IF (line >= lineLast) THEN
			IF (newSXIP >= funcAfterAddr[exeFunction]) THEN GOTO InvalidReturnAddr
			line = lineLast
		END IF
	END IF
	sxip = lineAddr[exeFunction, line]
	exceptionContext.eip = sxip

	redisplay = $$TRUE
	reportBogusRename = $$TRUE
	RestoreTextToProg (redisplay, reportBogusRename)	' resets BPs if necessary

	SELECT CASE continueCommand
		CASE $$BreakContinueToCursor
					BreakContinuePrep (continueCommand, func, 0)
		CASE $$BreakContinueStepLocal
					BreakContinuePrep (continueCommand, func, 0)
		CASE $$BreakContinueStepGlobal
					BreakContinuePrep (continueCommand, 0, 0)
		CASE $$BreakContinueRunning
					BreakContinuePrep (continueCommand, 0, 0)
	END SELECT
'
	GOSUB SetExceptionInfo
'	PRINT "  Return Address = "; HEX$(sxip,8); ":  "; XxxDisassemble$(sxip, $$TRUE)
'
	signalEntry = $$FALSE
	ClearRuntimeError ()
	IF environmentActive THEN
		SetCurrentStatus ($$StatusRunning, 0)
		ResetDataDisplays ($$InitiatingRun)
	END IF
'
'	SetAlarm (100)									' Unused in NT
'	merror = MakeUserCodeRX ()			' NT:  Not required
'
	XgrSetCursor (userCursor, 0)
	XgrSetCursorOverride (userCursorOverride, 0)
	sigNumber = 0
	##TRAPVECTOR = 510							' Default trap is normal breakpoint
	##SIGNALACTIVE = entrySIGNALACTIVE
	##WHOMASK = entryWHOMASK
	RETURN ($$EXCEPTION_CONTINUE_EXECUTION)
'
InvalidReturnAddr:
	Message (" RunContinue \n\n invalid return address \n\n " + HEXX$(sxip,8) + " ")
END SUB
'
' *****  GetExceptionInfo  *****
'
SUB GetExceptionInfo
'	PRINT "XitMain() : GetExceptionInfo"
	addrExceptionRecord		= XLONGAT (signalInfo, [0])
	addrExceptionContext	= XLONGAT (signalInfo, [1])
	FOR i = 0 TO (SIZE(EXCEPTION_RECORD) >> 2) - 1
		XLONGAT(&exceptionRecord,[i]) = XLONGAT(addrExceptionRecord,[i])
	NEXT i
	FOR i = 0 TO (SIZE(EXCEPTION_CONTEXT) >> 2) - 1
		reg = XLONGAT(addrExceptionContext,[i])
		XLONGAT(&exceptionContext,[i]) = reg
		XLONGAT(&exceptionContextOrig,[i]) = reg
	NEXT i
'	PRINT "exceptionRecord.exceptionAddress = "; HEX$(exceptionRecord.exceptionAddress,8);; HEX$(addrExceptionRecord,8);; HEX$(addrExceptionContext,8)
'	PRINT "exceptionContext.flags.eip.ebp.esp = "; HEX$(exceptionContext.contextFlags,8);; HEX$(exceptionContext.eip,8);; HEX$(exceptionContext.ebp,8);; HEX$(exceptionContext.esp,8)
END SUB
'
' *****  SetExceptionInfo  *****
'
SUB SetExceptionInfo
' exceptionRecord.exceptionAddress:		ENTRY (Original) address
' exceptionContext.eip:								CONTINUE address
'
'	PRINT "Set Exception Address: "; HEX$(exceptionContext.eip,8)
'
	IF ((sigNumber >= $$ExceptionDenormal) AND (sigNumber <= $$ExceptionUnderflow)) THEN
		IFZ fpEnv[] THEN DIM fpEnv[6]
		XxxGetFPEnvironment (@fpEnv[])												' Reset above
		exceptionContext.floatSave.controlWord		= fpEnv[0]
		exceptionContext.floatSave.statusWord			= fpEnv[1]
		exceptionContext.floatSave.tagWord				= fpEnv[2]
		exceptionContext.floatSave.errorOffset		= fpEnv[3]
		exceptionContext.floatSave.errorSelector	= fpEnv[4]
		exceptionContext.floatSave.dataOffset			= fpEnv[5]
		exceptionContext.floatSave.dataSelector		= fpEnv[6]
		FOR i = 0 TO 79
			exceptionContext.floatSave.registerArea[i] = 0
		NEXT i
'		PRINT "Floating point info:"
'		PRINT "  control word = "; HEX$(exceptionContext.floatSave.controlWord, 8)
'		PRINT "  status word  = "; HEX$(exceptionContext.floatSave.statusWord, 8)
'		PRINT "  tag word     = "; HEX$(exceptionContext.floatSave.tagWord, 8)
'		PRINT "  errorOffset  = "; HEX$(exceptionContext.floatSave.errorOffset, 8)
'		PRINT "  errorSelect  = "; HEX$(exceptionContext.floatSave.errorSelector, 8)
'		PRINT "  dataOffset   = "; HEX$(exceptionContext.floatSave.dataOffset, 8)
'		PRINT "  dataSelector = "; HEX$(exceptionContext.floatSave.dataSelector, 8)
'		PRINT "  cr0NpxState  = "; HEX$(exceptionContext.floatSave.cr0NpxState, 8)
'		a$ = "  Registers    = "
'		k = 0
'		FOR i = 0 TO 3
'			FOR j = 0 TO 19
'				a$ = a$ + HEX$(exceptionContext.floatSave.registerArea[k], 2)
'				INC k
'			NEXT j
'			a$ = a$ + "\n"
'			IF (i < 3) THEN a$ = a$ + "                 "
'		NEXT i
'		PRINT a$
	END IF
'
	exceptionRecord.exceptionAddress = exceptionContext.eip
	addrExceptionRecord		= XLONGAT (signalInfo, [0])
	addrExceptionContext	= XLONGAT (signalInfo, [1])
	FOR i = 0 TO (SIZE(EXCEPTION_RECORD) >> 2) - 1
		XLONGAT(addrExceptionRecord,[i]) = XLONGAT(&exceptionRecord,[i])
	NEXT i
	FOR i = 0 TO (SIZE(EXCEPTION_CONTEXT) >> 2) - 1
		XLONGAT(addrExceptionContext,[i]) = XLONGAT(&exceptionContext,[i])
	NEXT i
END SUB
END FUNCTION
'
'
' ############################
' #####  XitVersion$ ()  #####
' ############################
'
FUNCTION  XitVersion$ ()
'
	version$ = VERSION$ (0)
	RETURN (version$)
END FUNCTION
'
'
' ########################
' #####  Welcome ()  #####
' ########################
'
FUNCTION  Welcome ()
	SHARED  notifyTime$$
	SHARED  expireTime$$
	SHARED  timeExpired
	SHARED  notifyDays
	SHARED  totalDays
	SHARED  deltaDays
	SHARED  daysLeft
	STATIC  path$
	STATIC  UBYTE  byte[]
	STATIC  FILEINFO  fileinfo[]
	STATIC  SYSTEMTIME  systemTime
	STATIC	systemTime$$
'
	$OneDay = 864000000000$$			' in units of 100 nano-seconds
'
	XstGetFileAttributes ("$XBDIR/templates/version.xxx", @attributes)
'	PRINT "attributes = "; attributes
	IFZ attributes THEN RETURN (0)
	XstLoadString (@"$XBDIR/templates/version.xxx", @version$)
'	PRINT "version$ = <"; version$; ">"
	IFZ version$ THEN RETURN (0)
	dot = INSTR (version$, ".")
	nl = INSTR (version$, "\n")
'	PRINT "dot,nl = "; dot; nl
	IFZ dot THEN RETURN (0)
	IF nl THEN RETURN (0)
	total$ = LEFT$ (version$, dot-1)
'	PRINT "total$ = "; total$
	IFZ total$ THEN RETURN (0)
	total = XLONG (total$)
'	PRINT "total = "; total
	notify$ = MID$ (version$, dot+1)
'	PRINT "notify$ = "; notify$
	IFZ notify$ THEN RETURN (0)
	notify = XLONG (notify$)
'	PRINT "notify = "; notify
	notify$$ = notify * $OneDay
	total$$ = total * $OneDay
	notifyDays = notify
	totalDays = total
'
	IF (total <= 0) THEN RETURN (0)
	IF (notify <= 0) THEN RETURN (0)
'	IF (total MOD 30) THEN RETURN (0)			' must be multiple of 30 days
'	IF (notify MOD 30) THEN RETURN (0)		' ditto
	IF (total < notify) THEN RETURN (0)		' total must be >= notify
'
'	PRINT total, notify, total$$, notify$$
'
	path$ = NULL$ (260)
	pathAddr = &path$
	pathSize = 260
'
	size = GetWindowsDirectoryA (pathAddr, pathSize)
	win$ = CSTRING$ (pathAddr)
	IFZ win$ THEN PRINT "[-1]" : RETURN (-1)
'	PRINT win$
'
	GetSystemTime (&systemTime)
	SystemTimeToFileTime (&systemTime, &systemTime$$)
'	PRINT systemTime$$
	IFZ systemTime$$ THEN PRINT "[-2]" : RETURN (-2)
'
	DIM file$[]
	stampFile$ = win$ + "\\windatum.ini"
'
	sf = OPEN (stampFile$, $$RD)
	IF (sf > 0) THEN
		lsf = LOF (sf)
		CLOSE (sf)
		IF (lsf != 64) THEN RETURN (0)
'		IF (lsf < 60) THEN XstDeleteFile (@stampFile$)
	END IF
'
	XstGetFilesAndAttributes (@stampFile$, -1, @file$[], @fileinfo[])
'	PRINT stampFile$
'
	IFZ file$[] THEN
'		PRINT "a..."
		DIM file$[]
		DIM fileinfo[]
'		PRINT win$, HEX$($$FileDirectory,8), UBOUND(file$[]), UBOUND(fileinfo[])
		XstGetFilesAndAttributes (win$, $$FileDirectory, @file$[], @fileinfo[])
'		PRINT win$, HEX$($$FileDirectory,8), UBOUND(file$[]), UBOUND(fileinfo[])
		IFZ file$[] THEN PRINT "[-3]" : RETURN (-3)
'		PRINT file$[0]
'
		createTime$$ = GMAKE (fileinfo[0].createTimeHigh, fileinfo[0].createTimeLow)
		accessTime$$ = GMAKE (fileinfo[0].accessTimeHigh, fileinfo[0].accessTimeLow)
		modifyTime$$ = GMAKE (fileinfo[0].modifyTimeHigh, fileinfo[0].modifyTimeLow)
		notifyTime$$ = 0
		expireTime$$ = 0
'
'		PRINT createTime$$, accessTime$$, modifyTime$$
'
		IFZ createTime$$ THEN createTime$$ = modifyTime$$
		IFZ accessTime$$ THEN accessTime$$ = modifyTime$$
		IFZ modifyTime$$ THEN PRINT "[-4]" : RETURN (-4)
'
		ofile = OPEN (stampFile$, $$WR)
		IF (ofile <= 0) THEN PRINT "[-5]" : RETURN (-5)
		WRITE [ofile], createTime$$
		WRITE [ofile], accessTime$$
		WRITE [ofile], modifyTime$$
		WRITE [ofile], systemTime$$
		WRITE [ofile], notifyTime$$
		WRITE [ofile], expireTime$$
		PRINT [ofile], "! Don't Delete !";
		CLOSE (ofile)
		handle = CreateFileA (&stampFile$, 0xC0000000, 0, 0, 3, 0x0080, 0)
		IF (handle = -1) THEN PRINT "[-6]" : RETURN (-6)
		SetFileTime (handle, &createTime$$, &accessTime$$, &modifyTime$$)
		CloseHandle (handle)
		daysLeft = total
		return = total
	ELSE
'		PRINT "b..."
'		PRINT "file$[] not empty : "; file$[0]
		ifile = OPEN (stampFile$, $$RW)
'		PRINT "ifile ="; ifile
		IF (ifile <= 0) THEN PRINT "[-7]" : RETURN (-7)

		READ [ifile], createTime$$
		READ [ifile], accessTime$$
		READ [ifile], modifyTime$$
		READ [ifile], sisterTime$$
		READ [ifile], notifyTime$$
		READ [ifile], expireTime$$
		deltaTime$$ = systemTime$$ - sisterTime$$
'
'		PRINT createTime$$, accessTime$$, modifyTime$$, systemTime$$, sisterTime$$, notifyTime$$, expireTime$$, deltaTime$$
'
		deltaDays = deltaTime$$ / $OneDay
		daysLeft = total - deltaDays + 1
		IF (daysLeft >= 0) THEN notify = $$FALSE
'
'		PRINT deltaDays, daysLeft, notify
'
		IF expireTime$$ THEN						' no more chances
			CLOSE (ifile)
			RETURN (0x80000000)
		END IF
'
		IF notifyTime$$ THEN
			SEEK (ifile, 40)
			WRITE [ifile], systemTime$$		' write expireTime$$
			CLOSE (ifile)
			RETURN (0x80000000)
		END IF
'
		IF (deltaTime$$ < 0) THEN				' now time before first run time
			CLOSE (ifile)
			PRINT "[-8]"
			RETURN (-8)
		END IF
'
		IF (deltaDays < 0) THEN					' now date before first run date
			CLOSE (ifile)
			PRINT "[-9]"
			RETURN (-9)
		END IF
'
		SEEK (ifile, 32)								' offset to notifyTime$$
		return = daysLeft
'
		IF notify THEN
			WRITE [ifile], systemTime$$		' write notifyTime$$
			return = 0x80000000						' past time, but allow this one last time
		END IF
		CLOSE (ifile)
	END IF
	RETURN (return)
END FUNCTION
'#incXitDbg
'
'
' ###########################
' #####  FreeAliens ()  #####
' ###########################
'
FUNCTION  FreeAliens ()
	STATIC heads[]
'
	IFZ heads[] THEN DIM heads[1000]
	headaddr = ##DYNO
	DO
		freecount = 0
		DO
			upLink = XLONGAT (headaddr)
			alloc  = XLONGAT (headaddr, [1])
			checks = XLONGAT (headaddr, [3])
			IF (alloc < 0) THEN
				IF checks{{1,24}} THEN
					heads[freecount] = headaddr + 0x0010
					INC freecount
				END IF
			END IF
			headaddr = headaddr + upLink
		LOOP WHILE (upLink AND (freecount <= 1000))
'
		oneMore = $$FALSE
		IF freecount THEN
			DO WHILE upLink										' Point to next allocation before free
				upLink = XLONGAT (headaddr)		'   (unallocated may disappear)
				alloc  = XLONGAT (headaddr, [1])
				checks = XLONGAT (headaddr, [3])
				IF (alloc < 0) THEN
					IFZ upLink THEN oneMore = $$TRUE
					EXIT DO
				END IF
				headaddr = headaddr + upLink
			LOOP
			totalAliens = totalAliens + freecount
			i = 0
			DO
				freeaddr = heads[i]
'				PRINT "  Free #"; i;;; HEX$(freeaddr, 8)
				free (freeaddr)
				INC i
			LOOP UNTIL (i = freecount)
		END IF
	LOOP WHILE (upLink OR oneMore)
'
'	IF (totalAliens <= 0) THEN
'		Message (" FreeAliens \n\n no aliens")
'	ELSE
'		Message (" FreeAliens \n\n found " + STRING$(totalAliens) + " aliens ")
'	END IF
END FUNCTION
'
'
' ########################
' #####  InitGui ()  #####
' ########################
'
' Initialize message numbers, gridTypes
'
FUNCTION  InitGui ()
	SHARED	graphicsInitialized
	SHARED	waitCursor
	SHARED  romanFont
	SHARED	messageFont
	SHARED  courierFont
	SHARED  welcomeFont
	SHARED  verdanaFont
	SHARED  comicFont
	SHARED  comicBigFont
	SHARED  buttonFont
	SHARED  labelFont
	SHARED	I_Information
'
	IF graphicsInitialized THEN RETURN ($$FALSE)
	error = Xui()															' initialize Xgr/Xui
	IF error THEN
		PRINT "Xit() : error initializing GraphicsDesigner or GuiDesigner"
		graphicsInitialized = $$FALSE
		RETURN ($$TRUE)									' abort if server dead
	END IF
	graphicsInitialized = $$TRUE
'
	XgrGetDisplaySize ("", @#displayWidth, @#displayHeight, @#windowBorderWidth, @#windowTitleHeight)
'
'
' ******************************
' *****  Register Cursors  *****
' ******************************
'
	XgrRegisterCursor (@"default",      @#cursorDefault)
	XgrRegisterCursor (@"arrow",        @#cursorArrow)
	XgrRegisterCursor (@"n",            @#cursorN)
	XgrRegisterCursor (@"s",            @#cursorS)
	XgrRegisterCursor (@"e",            @#cursorE)
	XgrRegisterCursor (@"w",            @#cursorW)
	XgrRegisterCursor (@"ns",           @#cursorArrowsNS)
	XgrRegisterCursor (@"ns",           @#cursorArrowsSN)
	XgrRegisterCursor (@"ew",           @#cursorArrowsEW)
	XgrRegisterCursor (@"ew",           @#cursorArrowsWE)
	XgrRegisterCursor (@"nwse",         @#cursorArrowsNWSE)
	XgrRegisterCursor (@"nesw",         @#cursorArrowsNESW)
	XgrRegisterCursor (@"all",          @#cursorArrowsAll)
	XgrRegisterCursor (@"plus",         @#cursorPlus)
	XgrRegisterCursor (@"wait",         @#cursorWait)
	XgrRegisterCursor (@"insert",       @#cursorInsert)
	XgrRegisterCursor (@"crosshair",    @#cursorCrosshair)
	XgrRegisterCursor (@"hourglass",    @#cursorHourglass)
	XgrRegisterCursor (@"hand",         @#cursorHand)
	XgrRegisterCursor (@"help",         @#cursorHelp)
'
	#defaultCursor = #cursorDefault
	waitCursor = #cursorHourglass
'
'
' ****************************
' *****  Register Fonts  *****
' ****************************
'
	romanFont = 0
	comicFont = 0
	comicBigFont = 0
	courierFont = 0
	messageFont = 0
	welcomeFont = 0
	verdanaFont = 0
	buttonFont = 0
	labelFont = 0
	XgrGetFontNames (@count, @fontNames$[])			' TrueType only
	IF count THEN
		FOR i = 0 TO count - 1
			fontName$ = fontNames$[i]
			fontName$ = LCASE$(fontName$)
			SELECT CASE fontName$
				CASE "courier new"		:	point = 12
																fontSize = point * 20
																XgrCreateFont (@courierFont, @"Courier New", fontSize, 700, $$FALSE, 0)
				CASE "times new roman":	point = 32
																fontSize = point * 20
																XgrCreateFont (@romanBigFont, @"Times New Roman", fontSize, 600, $$FALSE, 0)
																point = 20
																fontSize = point * 20
																XgrCreateFont (@romanFont, @"Times New Roman", fontSize, 400, $$FALSE, 0)
				CASE "verdana"				: point = 16
																fontSize = point * 20
																XgrCreateFont (@verdanaFont, @"Verdana", fontSize, 700, $$FALSE, 0)
				CASE "comic sans ms"	: point = 13
																fontSize = point * 20
																XgrCreateFont (@comicFont, @"Comic Sans MS", fontSize, 600, $$FALSE, 0)
																point = 16
																fontSize = point * 20
																XgrCreateFont (@welcomeFont, @"Comic Sans MS", fontSize, 400, $$FALSE, 0)
																point = 24
																fontSize = point * 20
																XgrCreateFont (@comicBigFont, @"Comic Sans MS", fontSize, 400, $$FALSE, 0)
			END SELECT
		NEXT i
		SELECT CASE TRUE
			CASE comicBigFont	: messageFont = comicBigFont
			CASE comicFont		: messageFont = comicFont
			CASE verdanaFont	: messageFont = verdanaFont
			CASE romanBigFont	: messageFont = romanBigFont
			CASE welcomeFont	: messageFont = welcomeFont
			CASE romanFont		: messageFont = romanFont
		END SELECT
		SELECT CASE TRUE
			CASE welcomeFont	: welcomeFont = welcomeFont
			CASE comicFont		: welcomeFont = comicFont
			CASE comicBigFont	: welcomeFont = comicBigFont
			CASE verdanaFont	: welcomeFont = verdanaFont
			CASE romanFont		: welcomeFont = romanFont
		END SELECT
		SELECT CASE TRUE
			CASE comicFont		: labelFont = comicFont
													buttonFont = comicFont
		END SELECT
'		XstLog ("romanFont    = " + STRING$(romanFont))
'		XstLog ("comicFont    = " + STRING$(comicFont))
'		XstLog ("comicBigFont = " + STRING$(comicBigFont))
'		XstLog ("verdanaFont  = " + STRING$(verdanaFont))
'		XstLog ("courierFont  = " + STRING$(courierFont))
'		XstLog ("welcomeFont  = " + STRING$(welcomeFont))
'		XstLog ("messageFont  = " + STRING$(messageFont))
	END IF
'
'
' ****************************
' *****  Register Icons  *****
' ****************************
'
	XgrRegisterIcon (@"Asterisk", @I_Information)
'
'
' ******************************
' *****  Register Messages *****  Create message numbers for message names
' ******************************
'
	XgrRegisterMessage (@"Blowback",										@#Blowback)
	XgrRegisterMessage (@"Callback",										@#Callback)
	XgrRegisterMessage (@"Cancel",											@#Cancel)
	XgrRegisterMessage (@"Change",											@#Change)
	XgrRegisterMessage (@"CloseWindow",									@#CloseWindow)
	XgrRegisterMessage (@"ContextChange",								@#ContextChange)
	XgrRegisterMessage (@"Create",											@#Create)
	XgrRegisterMessage (@"CreateValueArray",						@#CreateValueArray)
	XgrRegisterMessage (@"CreateWindow",								@#CreateWindow)
	XgrRegisterMessage (@"CursorH",											@#CursorH)
	XgrRegisterMessage (@"CursorV",											@#CursorV)
	XgrRegisterMessage (@"Deselected",									@#Deselected)
	XgrRegisterMessage (@"Destroy",											@#Destroy)
	XgrRegisterMessage (@"Destroyed",										@#Destroyed)
	XgrRegisterMessage (@"DestroyWindow",								@#DestroyWindow)
	XgrRegisterMessage (@"Disable",											@#Disable)
	XgrRegisterMessage (@"Disabled",										@#Disabled)
	XgrRegisterMessage (@"Displayed",										@#Displayed)
	XgrRegisterMessage (@"DisplayWindow",								@#DisplayWindow)
	XgrRegisterMessage (@"Enable",											@#Enable)
	XgrRegisterMessage (@"Enabled",											@#Enabled)
	XgrRegisterMessage (@"Enter",												@#Enter)
	XgrRegisterMessage (@"ExitMessageLoop",							@#ExitMessageLoop)
	XgrRegisterMessage (@"Find",												@#Find)
	XgrRegisterMessage (@"FindForward",									@#FindForward)
	XgrRegisterMessage (@"FindReverse",									@#FindReverse)
	XgrRegisterMessage (@"Forward",											@#Forward)
	XgrRegisterMessage (@"GetAlign",										@#GetAlign)
	XgrRegisterMessage (@"GetBorder",										@#GetBorder)
	XgrRegisterMessage (@"GetBorderOffset",							@#GetBorderOffset)
	XgrRegisterMessage (@"GetCallback",									@#GetCallback)
	XgrRegisterMessage (@"GetCallbackArgs",							@#GetCallbackArgs)
	XgrRegisterMessage (@"GetCan",											@#GetCan)
	XgrRegisterMessage (@"GetCharacterMapArray",				@#GetCharacterMapArray)
	XgrRegisterMessage (@"GetCharacterMapEntry",				@#GetCharacterMapEntry)
	XgrRegisterMessage (@"GetClipGrid",									@#GetClipGrid)
	XgrRegisterMessage (@"GetColor",										@#GetColor)
	XgrRegisterMessage (@"GetColorExtra",								@#GetColorExtra)
	XgrRegisterMessage (@"GetCursor",										@#GetCursor)
	XgrRegisterMessage (@"GetCursorXY",									@#GetCursorXY)
	XgrRegisterMessage (@"GetDisplay",									@#GetDisplay)
	XgrRegisterMessage (@"GetEnclosedGrids",						@#GetEnclosedGrids)
	XgrRegisterMessage (@"GetEnclosingGrid",						@#GetEnclosingGrid)
	XgrRegisterMessage (@"GetFocusColor",								@#GetFocusColor)
	XgrRegisterMessage (@"GetFocusColorExtra",					@#GetFocusColorExtra)
	XgrRegisterMessage (@"GetFont",											@#GetFont)
	XgrRegisterMessage (@"GetFontMetrics",							@#GetFontMetrics)
	XgrRegisterMessage (@"GetFontNumber",								@#GetFontNumber)
	XgrRegisterMessage (@"GetGridFunction",							@#GetGridFunction)
	XgrRegisterMessage (@"GetGridFunctionName",					@#GetGridFunctionName)
	XgrRegisterMessage (@"GetGridName",									@#GetGridName)
	XgrRegisterMessage (@"GetGridNumber",								@#GetGridNumber)
	XgrRegisterMessage (@"GetGridProperties",						@#GetGridProperties)
	XgrRegisterMessage (@"GetGridType",									@#GetGridType)
	XgrRegisterMessage (@"GetGridTypeName",							@#GetGridTypeName)
	XgrRegisterMessage (@"GetGroup",										@#GetGroup)
	XgrRegisterMessage (@"GetHelp",											@#GetHelp)
	XgrRegisterMessage (@"GetHelpFile",									@#GetHelpFile)
	XgrRegisterMessage (@"GetHelpString",								@#GetHelpString)
	XgrRegisterMessage (@"GetHelpStrings",							@#GetHelpStrings)
	XgrRegisterMessage (@"GetHintString",								@#GetHintString)
	XgrRegisterMessage (@"GetImage",										@#GetImage)
	XgrRegisterMessage (@"GetImageCoords",							@#GetImageCoords)
	XgrRegisterMessage (@"GetIndent",										@#GetIndent)
	XgrRegisterMessage (@"GetInfo",											@#GetInfo)
	XgrRegisterMessage (@"GetJustify",									@#GetJustify)
	XgrRegisterMessage (@"GetKeyboardFocus",						@#GetKeyboardFocus)
	XgrRegisterMessage (@"GetKeyboardFocusGrid",				@#GetKeyboardFocusGrid)
	XgrRegisterMessage (@"GetKidArray",									@#GetKidArray)
	XgrRegisterMessage (@"GetKidNumber",								@#GetKidNumber)
	XgrRegisterMessage (@"GetKids",											@#GetKids)
	XgrRegisterMessage (@"GetKind",											@#GetKind)
	XgrRegisterMessage (@"GetMaxMinSize",								@#GetMaxMinSize)
	XgrRegisterMessage (@"GetMenuEntryArray",						@#GetMenuEntryArray)
	XgrRegisterMessage (@"GetMessageFunc",							@#GetMessageFunc)
	XgrRegisterMessage (@"GetMessageFuncArray",					@#GetMessageFuncArray)
	XgrRegisterMessage (@"GetMessageSub",								@#GetMessageSub)
	XgrRegisterMessage (@"GetMessageSubArray",					@#GetMessageSubArray)
	XgrRegisterMessage (@"GetModalInfo",								@#GetModalInfo)
	XgrRegisterMessage (@"GetModalWindow",							@#GetModalWindow)
	XgrRegisterMessage (@"GetParent",										@#GetParent)
	XgrRegisterMessage (@"GetPosition",									@#GetPosition)
	XgrRegisterMessage (@"GetProtoInfo",								@#GetProtoInfo)
	XgrRegisterMessage (@"GetRedrawFlags",							@#GetRedrawFlags)
	XgrRegisterMessage (@"GetSize",											@#GetSize)
	XgrRegisterMessage (@"GetSmallestSize",							@#GetSmallestSize)
	XgrRegisterMessage (@"GetState",										@#GetState)
	XgrRegisterMessage (@"GetStyle",										@#GetStyle)
	XgrRegisterMessage (@"GetTabArray",									@#GetTabArray)
	XgrRegisterMessage (@"GetTabWidth",									@#GetTabWidth)
	XgrRegisterMessage (@"GetTextArray",								@#GetTextArray)
	XgrRegisterMessage (@"GetTextArrayBounds",					@#GetTextArrayBounds)
	XgrRegisterMessage (@"GetTextArrayLine",						@#GetTextArrayLine)
	XgrRegisterMessage (@"GetTextArrayLines",						@#GetTextArrayLines)
	XgrRegisterMessage (@"GetTextCursor",								@#GetTextCursor)
	XgrRegisterMessage (@"GetTextFilename",							@#GetTextFilename)
	XgrRegisterMessage (@"GetTextPosition",							@#GetTextPosition)
	XgrRegisterMessage (@"GetTextSelection",						@#GetTextSelection)
	XgrRegisterMessage (@"GetTextSpacing",							@#GetTextSpacing)
	XgrRegisterMessage (@"GetTextString",								@#GetTextString)
	XgrRegisterMessage (@"GetTextStrings",							@#GetTextStrings)
	XgrRegisterMessage (@"GetTexture",									@#GetTexture)
	XgrRegisterMessage (@"GetTimer",										@#GetTimer)
	XgrRegisterMessage (@"GetValue",										@#GetValue)
	XgrRegisterMessage (@"GetValueArray",								@#GetValueArray)
	XgrRegisterMessage (@"GetValues",										@#GetValues)
	XgrRegisterMessage (@"GetWindow",										@#GetWindow)
	XgrRegisterMessage (@"GetWindowFunction",						@#GetWindowFunction)
	XgrRegisterMessage (@"GetWindowGrid",								@#GetWindowGrid)
	XgrRegisterMessage (@"GetWindowIcon",								@#GetWindowIcon)
	XgrRegisterMessage (@"GetWindowSize",								@#GetWindowSize)
	XgrRegisterMessage (@"GetWindowTitle",							@#GetWindowTitle)
	XgrRegisterMessage (@"GotKeyboardFocus",						@#GotKeyboardFocus)
	XgrRegisterMessage (@"GrabArray",										@#GrabArray)
	XgrRegisterMessage (@"GrabTextArray",								@#GrabTextArray)
	XgrRegisterMessage (@"GrabTextString",							@#GrabTextString)
	XgrRegisterMessage (@"GrabValueArray",							@#GrabValueArray)
	XgrRegisterMessage (@"Help",												@#Help)
	XgrRegisterMessage (@"Hidden",											@#Hidden)
	XgrRegisterMessage (@"HideTextCursor",							@#HideTextCursor)
	XgrRegisterMessage (@"HideWindow",									@#HideWindow)
	XgrRegisterMessage (@"Initialize",									@#Initialize)
	XgrRegisterMessage (@"Initialized",									@#Initialized)
	XgrRegisterMessage (@"Inline",											@#Inline)
	XgrRegisterMessage (@"InquireText",									@#InquireText)
	XgrRegisterMessage (@"KeyboardFocusBackward",				@#KeyboardFocusBackward)
	XgrRegisterMessage (@"KeyboardFocusForward",				@#KeyboardFocusForward)
	XgrRegisterMessage (@"KeyDown",											@#KeyDown)
	XgrRegisterMessage (@"KeyUp",												@#KeyUp)
	XgrRegisterMessage (@"LostKeyboardFocus",						@#LostKeyboardFocus)
	XgrRegisterMessage (@"LostTextSelection",						@#LostTextSelection)
	XgrRegisterMessage (@"Maximized",										@#Maximized)
	XgrRegisterMessage (@"MaximizeWindow",							@#MaximizeWindow)
	XgrRegisterMessage (@"Maximum",											@#Maximum)
	XgrRegisterMessage (@"Minimized",										@#Minimized)
	XgrRegisterMessage (@"MinimizeWindow",							@#MinimizeWindow)
	XgrRegisterMessage (@"Minimum",											@#Minimum)
	XgrRegisterMessage (@"MonitorContext",							@#MonitorContext)
	XgrRegisterMessage (@"MonitorHelp",									@#MonitorHelp)
	XgrRegisterMessage (@"MonitorKeyboard",							@#MonitorKeyboard)
	XgrRegisterMessage (@"MonitorMouse",								@#MonitorMouse)
	XgrRegisterMessage (@"MouseDown",										@#MouseDown)
	XgrRegisterMessage (@"MouseDrag",										@#MouseDrag)
	XgrRegisterMessage (@"MouseEnter",									@#MouseEnter)
	XgrRegisterMessage (@"MouseExit",										@#MouseExit)
	XgrRegisterMessage (@"MouseMove",										@#MouseMove)
	XgrRegisterMessage (@"MouseUp",											@#MouseUp)
	XgrRegisterMessage (@"MouseWheel",									@#MouseWheel)
	XgrRegisterMessage (@"MuchLess",										@#MuchLess)
	XgrRegisterMessage (@"MuchMore",										@#MuchMore)
	XgrRegisterMessage (@"Notify",											@#Notify)
	XgrRegisterMessage (@"OneLess",											@#OneLess)
	XgrRegisterMessage (@"OneMore",											@#OneMore)
	XgrRegisterMessage (@"PokeArray",										@#PokeArray)
	XgrRegisterMessage (@"PokeTextArray",								@#PokeTextArray)
	XgrRegisterMessage (@"PokeTextString",							@#PokeTextString)
	XgrRegisterMessage (@"PokeValueArray",							@#PokeValueArray)
	XgrRegisterMessage (@"Print",												@#Print)
	XgrRegisterMessage (@"Redraw",											@#Redraw)
	XgrRegisterMessage (@"RedrawGrid",									@#RedrawGrid)
	XgrRegisterMessage (@"RedrawLines",									@#RedrawLines)
	XgrRegisterMessage (@"Redrawn",											@#Redrawn)
	XgrRegisterMessage (@"RedrawText",									@#RedrawText)
	XgrRegisterMessage (@"RedrawWindow",								@#RedrawWindow)
	XgrRegisterMessage (@"Replace",											@#Replace)
	XgrRegisterMessage (@"ReplaceForward",							@#ReplaceForward)
	XgrRegisterMessage (@"ReplaceReverse",							@#ReplaceReverse)
	XgrRegisterMessage (@"Reset",												@#Reset)
	XgrRegisterMessage (@"Resize",											@#Resize)
	XgrRegisterMessage (@"Resized",											@#Resized)
	XgrRegisterMessage (@"ResizeNot",										@#ResizeNot)
	XgrRegisterMessage (@"ResizeWindow",								@#ResizeWindow)
	XgrRegisterMessage (@"ResizeWindowToGrid",					@#ResizeWindowToGrid)
	XgrRegisterMessage (@"Resized",											@#Resized)
	XgrRegisterMessage (@"Reverse",											@#Reverse)
	XgrRegisterMessage (@"ScrollH",											@#ScrollH)
	XgrRegisterMessage (@"ScrollV",											@#ScrollV)
	XgrRegisterMessage (@"Select",											@#Select)
	XgrRegisterMessage (@"Selected",										@#Selected)
	XgrRegisterMessage (@"Selection",										@#Selection)
	XgrRegisterMessage (@"SelectWindow",								@#SelectWindow)
	XgrRegisterMessage (@"SetAlign",										@#SetAlign)
	XgrRegisterMessage (@"SetBorder",										@#SetBorder)
	XgrRegisterMessage (@"SetBorderOffset",							@#SetBorderOffset)
	XgrRegisterMessage (@"SetCallback",									@#SetCallback)
	XgrRegisterMessage (@"SetCan",											@#SetCan)
	XgrRegisterMessage (@"SetCharacterMapArray",				@#SetCharacterMapArray)
	XgrRegisterMessage (@"SetCharacterMapEntry",				@#SetCharacterMapEntry)
	XgrRegisterMessage (@"SetClipGrid",									@#SetClipGrid)
	XgrRegisterMessage (@"SetColor",										@#SetColor)
	XgrRegisterMessage (@"SetColorAll",									@#SetColorAll)
	XgrRegisterMessage (@"SetColorExtra",								@#SetColorExtra)
	XgrRegisterMessage (@"SetColorExtraAll",						@#SetColorExtraAll)
	XgrRegisterMessage (@"SetCursor",										@#SetCursor)
	XgrRegisterMessage (@"SetCursorXY",									@#SetCursorXY)
	XgrRegisterMessage (@"SetDisplay",									@#SetDisplay)
	XgrRegisterMessage (@"SetFocusColor",								@#SetFocusColor)
	XgrRegisterMessage (@"SetFocusColorExtra",					@#SetFocusColorExtra)
	XgrRegisterMessage (@"SetFont",											@#SetFont)
	XgrRegisterMessage (@"SetFontNumber",								@#SetFontNumber)
	XgrRegisterMessage (@"SetGridFunction",							@#SetGridFunction)
	XgrRegisterMessage (@"SetGridFunctionName",					@#SetGridFunctionName)
	XgrRegisterMessage (@"SetGridName",									@#SetGridName)
	XgrRegisterMessage (@"SetGridProperties",						@#SetGridProperties)
	XgrRegisterMessage (@"SetGridType",									@#SetGridType)
	XgrRegisterMessage (@"SetGridTypeName",							@#SetGridTypeName)
	XgrRegisterMessage (@"SetGroup",										@#SetGroup)
	XgrRegisterMessage (@"SetHelp",											@#SetHelp)
	XgrRegisterMessage (@"SetHelpFile",									@#SetHelpFile)
	XgrRegisterMessage (@"SetHelpString",								@#SetHelpString)
	XgrRegisterMessage (@"SetHelpStrings",							@#SetHelpStrings)
	XgrRegisterMessage (@"SetHintString",								@#SetHintString)
	XgrRegisterMessage (@"SetImage",										@#SetImage)
	XgrRegisterMessage (@"SetImageCoords",							@#SetImageCoords)
	XgrRegisterMessage (@"SetIndent",										@#SetIndent)
	XgrRegisterMessage (@"SetInfo",											@#SetInfo)
	XgrRegisterMessage (@"SetJustify",									@#SetJustify)
	XgrRegisterMessage (@"SetKeyboardFocus",						@#SetKeyboardFocus)
	XgrRegisterMessage (@"SetKeyboardFocusGrid",				@#SetKeyboardFocusGrid)
	XgrRegisterMessage (@"SetKidArray",									@#SetKidArray)
	XgrRegisterMessage (@"SetMaxMinSize",								@#SetMaxMinSize)
	XgrRegisterMessage (@"SetMenuEntryArray",						@#SetMenuEntryArray)
	XgrRegisterMessage (@"SetMessageFunc",							@#SetMessageFunc)
	XgrRegisterMessage (@"SetMessageFuncArray",					@#SetMessageFuncArray)
	XgrRegisterMessage (@"SetMessageSub",								@#SetMessageSub)
	XgrRegisterMessage (@"SetMessageSubArray",					@#SetMessageSubArray)
	XgrRegisterMessage (@"SetModalWindow",							@#SetModalWindow)
	XgrRegisterMessage (@"SetParent",										@#SetParent)
	XgrRegisterMessage (@"SetPosition",									@#SetPosition)
	XgrRegisterMessage (@"SetRedrawFlags",							@#SetRedrawFlags)
	XgrRegisterMessage (@"SetSize",											@#SetSize)
	XgrRegisterMessage (@"SetState",										@#SetState)
	XgrRegisterMessage (@"SetStyle",										@#SetStyle)
	XgrRegisterMessage (@"SetTabArray",									@#SetTabArray)
	XgrRegisterMessage (@"SetTabWidth",									@#SetTabWidth)
	XgrRegisterMessage (@"SetTextArray",								@#SetTextArray)
	XgrRegisterMessage (@"SetTextArrayLine",						@#SetTextArrayLine)
	XgrRegisterMessage (@"SetTextArrayLines",						@#SetTextArrayLines)
	XgrRegisterMessage (@"SetTextCursor",								@#SetTextCursor)
	XgrRegisterMessage (@"SetTextFilename",							@#SetTextFilename)
	XgrRegisterMessage (@"SetTextSelection",						@#SetTextSelection)
	XgrRegisterMessage (@"SetTextSpacing",							@#SetTextSpacing)
	XgrRegisterMessage (@"SetTextString",								@#SetTextString)
	XgrRegisterMessage (@"SetTextStrings",							@#SetTextStrings)
	XgrRegisterMessage (@"SetTexture",									@#SetTexture)
	XgrRegisterMessage (@"SetTimer",										@#SetTimer)
	XgrRegisterMessage (@"SetValue",										@#SetValue)
	XgrRegisterMessage (@"SetValues",										@#SetValues)
	XgrRegisterMessage (@"SetValueArray",								@#SetValueArray)
	XgrRegisterMessage (@"SetWindowFunction",						@#SetWindowFunction)
	XgrRegisterMessage (@"SetWindowIcon",								@#SetWindowIcon)
	XgrRegisterMessage (@"SetWindowTitle",							@#SetWindowTitle)
	XgrRegisterMessage (@"ShowTextCursor",							@#ShowTextCursor)
	XgrRegisterMessage (@"ShowWindow",									@#ShowWindow)
	XgrRegisterMessage (@"SomeLess",										@#SomeLess)
	XgrRegisterMessage (@"SomeMore",										@#SomeMore)
	XgrRegisterMessage (@"StartTimer",									@#StartTimer)
	XgrRegisterMessage (@"SystemMessage",								@#SystemMessage)
	XgrRegisterMessage (@"TextDelete",									@#TextDelete)
	XgrRegisterMessage (@"TextEvent",										@#TextEvent)
	XgrRegisterMessage (@"TextInsert",									@#TextInsert)
	XgrRegisterMessage (@"TextModified",								@#TextModified)
	XgrRegisterMessage (@"TextReplace",									@#TextReplace)
	XgrRegisterMessage (@"TimeOut",											@#TimeOut)
	XgrRegisterMessage (@"Update",											@#Update)
	XgrRegisterMessage (@"WindowClose",									@#WindowClose)
	XgrRegisterMessage (@"WindowCreate",								@#WindowCreate)
	XgrRegisterMessage (@"WindowDeselected",						@#WindowDeselected)
	XgrRegisterMessage (@"WindowDestroy",								@#WindowDestroy)
	XgrRegisterMessage (@"WindowDestroyed",							@#WindowDestroyed)
	XgrRegisterMessage (@"WindowDisplay",								@#WindowDisplay)
	XgrRegisterMessage (@"WindowDisplayed",							@#WindowDisplayed)
	XgrRegisterMessage (@"WindowGetDisplay",						@#WindowGetDisplay)
	XgrRegisterMessage (@"WindowGetFunction",						@#WindowGetFunction)
	XgrRegisterMessage (@"WindowGetIcon",								@#WindowGetIcon)
	XgrRegisterMessage (@"WindowGetKeyboardFocusGrid",	@#WindowGetKeyboardFocusGrid)
	XgrRegisterMessage (@"WindowGetSelectedWindow",			@#WindowGetSelectedWindow)
	XgrRegisterMessage (@"WindowGetSize",								@#WindowGetSize)
	XgrRegisterMessage (@"WindowGetTitle",							@#WindowGetTitle)
	XgrRegisterMessage (@"WindowHelp",									@#WindowHelp)
	XgrRegisterMessage (@"WindowHide",									@#WindowHide)
	XgrRegisterMessage (@"WindowHidden",								@#WindowHidden)
	XgrRegisterMessage (@"WindowKeyDown",								@#WindowKeyDown)
	XgrRegisterMessage (@"WindowKeyUp",									@#WindowKeyUp)
	XgrRegisterMessage (@"WindowMaximize",							@#WindowMaximize)
	XgrRegisterMessage (@"WindowMaximized",							@#WindowMaximized)
	XgrRegisterMessage (@"WindowMinimize",							@#WindowMinimize)
	XgrRegisterMessage (@"WindowMinimized",							@#WindowMinimized)
	XgrRegisterMessage (@"WindowMonitorContext",				@#WindowMonitorContext)
	XgrRegisterMessage (@"WindowMonitorHelp",						@#WindowMonitorHelp)
	XgrRegisterMessage (@"WindowMonitorKeyboard",				@#WindowMonitorKeyboard)
	XgrRegisterMessage (@"WindowMonitorMouse",					@#WindowMonitorMouse)
	XgrRegisterMessage (@"WindowMouseDown",							@#WindowMouseDown)
	XgrRegisterMessage (@"WindowMouseDrag",							@#WindowMouseDrag)
	XgrRegisterMessage (@"WindowMouseEnter",						@#WindowMouseEnter)
	XgrRegisterMessage (@"WindowMouseExit",							@#WindowMouseExit)
	XgrRegisterMessage (@"WindowMouseMove",							@#WindowMouseMove)
	XgrRegisterMessage (@"WindowMouseUp",								@#WindowMouseUp)
	XgrRegisterMessage (@"WindowMouseWheel",						@#WindowMouseWheel)
	XgrRegisterMessage (@"WindowRedraw",								@#WindowRedraw)
	XgrRegisterMessage (@"WindowRegister",							@#WindowRegister)
	XgrRegisterMessage (@"WindowResize",								@#WindowResize)
	XgrRegisterMessage (@"WindowResized",								@#WindowResized)
	XgrRegisterMessage (@"WindowResizeToGrid",					@#WindowResizeToGrid)
	XgrRegisterMessage (@"WindowSelect",								@#WindowSelect)
	XgrRegisterMessage (@"WindowSelected",							@#WindowSelected)
	XgrRegisterMessage (@"WindowSetFunction",						@#WindowSetFunction)
	XgrRegisterMessage (@"WindowSetIcon",								@#WindowSetIcon)
	XgrRegisterMessage (@"WindowSetKeyboardFocusGrid",	@#WindowSetKeyboardFocusGrid)
	XgrRegisterMessage (@"WindowSetTitle",							@#WindowSetTitle)
	XgrRegisterMessage (@"WindowShow",									@#WindowShow)
	XgrRegisterMessage (@"WindowSystemMessage",					@#WindowSystemMessage)
	XgrRegisterMessage (@"LastMessage",									@#LastMessage)
'
	XgrGetDisplaySize ("", @#displayWidth, @#displayHeight, @#windowBorderWidth, @#windowTitleHeight)
END FUNCTION
'
'
'  ############################
'  #####  InitProgram ()  #####
'  ############################
'
FUNCTION  InitProgram ()
	SHARED  defaultDirectory$
	SHARED  fileType
	SHARED  UBYTE  charsetNonWhiteChar[]
	SHARED  heads[],  tempo[]
'
	Xst ()															' Initialize standard library
	' Don't initialize Xin; this can lead to problems on badly configured
	' systems.
'	Xin ()															' Initialize sockets library
	fileType = $$Text										' in case of fatal error
	##STANDALONE = $$FALSE							' Not running standalone
	GOSUB DefineCharsetArrays						'
	GOSUB InitTestHeaders								'
	MakeUserCodeSpace (0x200000)				' 2MB
	XstGetCurrentDirectory (@defaultDirectory$)
	RETURN
'
'	*****  DefineCharsetArrays  *****
'
SUB DefineCharsetArrays
'
' ***********************************
' *****  charsetNonWhiteChar[]  *****
' ***********************************
'
	DIM charsetNonWhiteChar [255]
  FOR i = 0 TO 255
    SELECT CASE TRUE
      CASE (i <=  32)	: charsetNonWhiteChar[i] = 0
      CASE (i >= 127)	: charsetNonWhiteChar[i] = 0
      CASE ELSE				: charsetNonWhiteChar[i] = i
    END SELECT
  NEXT i
END SUB
'
'	*****  InitTestHeaders  *****
'
SUB InitTestHeaders
	DIM tempo[31]
	DIM heads[32767]
END SUB
END FUNCTION
'
'
' ########################
' #####  Message ()  #####
' ########################
'
FUNCTION  Message (message$)
	SHARED  xitGrid,  environmentActive
'
	IFZ environmentActive THEN
		PRINT "\n" + message$
		RETURN
	END IF
'
	XuiMessage (@message$)
	RETURN
'
'
' old code - from previous main window design that had a TextLower
'
'	XuiSendMessage (xitGrid, #GetTextString, 0, 0, 0, 0, $$xitCommand, @text$)
'
'	IF text$ THEN
'		message$ = "\n" + message$ + "\n"
'		line = UBOUND(text$[])
'		pos = LEN(text$[line])
'		topLine = line + 1
'		cursorLine = line + 2
'		XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitCommand, @text$[])
'	ELSE
'		message$ = message$ + "\n"
'		line = 0
'		pos = 0
'		topLine = 0
'		cursorLine = 1
'	END IF
'
'
' old code follows
'
'	Insert message, display at top line
'
'	m$ = ".c " + message$
'	XuiSendMessage (xitGrid, #SetTextString, 0, 0, 0, 0, $$xitCommand, @m$)
'	XuiSendMessage (xitGrid, #SetTextCursor, 0, cursorLine, 0, topLine, $$xitCommand, 0)
'	XuiSendMessage (xitGrid, #Redraw, 0, 0, 0, 0, $$xitCommand, 0)
'	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
END FUNCTION
'#incXitDbg
'
'
' ##########################
' #####  PrintMenu ()  #####
' ##########################
'
FUNCTION  PrintMenu ()
	PRINT "?  = menu          <cr> = menu"
	PRINT "c  = continue        q  = quit xit"
	PRINT "m  = memory map      t  = table dump    cd = chunk dump"
	PRINT "th = test headers    h  = header dump   ch = count headers"
	PRINT "r  = registers"
	PRINT "c  = continue        after breakpoint or trap"
	PRINT "b  = breakpoint      b  <hex.address>"
	PRINT "u  = unbreakpoint    u  <hex.address>"
	PRINT "uu = remove all BPs  uu"
	PRINT "a  = assembly        a  <hex.start.addr>  <hex.length>"
	PRINT "xa = assembly > file xa <file.name>"
	PRINT "xb = assy object file    xb <object.file> <assy.file>"
	PRINT "d  = dump memory     d  <hex.start.address>   <hex.length>"
	PRINT "f  = fill memory     f  <hex.address>  <hex.length>  <hex.value>"
	PRINT "s  = substitute      s  <hex.address>"
	PRINT "l  = locate word     l  <hex.data>"
	PRINT "g  = go run user code at ##UCODE"
	PRINT "go = go run code     go <hex.goto.addr>  <hex.break.addr> ..."
END FUNCTION
'
'
'  ############################
'  #####  XitBlowback ()  #####
'  ############################
'
'	First entry from Xit just sets baseFrameAddr, other entries execute Blowback
'
' Blowbacks must be graceful--set the blowback flag
'  NEVER call XitBlowback from a callback routine (XWindows may break)
'
' Note:  XxxXntBlowback() must be last because it wastes the libraries
'        that user programs have brought in with IMPORT statements.
'        These libraries must not be wasted until all calls to these
'        libraries due to the other blowback functions are completed.
'        For example, XxxXuiBlowback() is gonna send #DestroyWindow
'        messages to all remaining library grid functions for which
'        a window exists.
'
FUNCTION  XitBlowback ()
	SHARED  blowback,  editFunction
	SHARED  environmentActive
	SHARED  defaultDirectory$
	STATIC  baseFrameAddr
'
	##WHOMASK = 0
	##LOCKOUT = $$FALSE
'
	IFZ baseFrameAddr THEN
		baseFrameAddr = XxxGetFrameAddr()
	ELSE
		XstChangeDirectory (@defaultDirectory$)			' reset to entry directory
		XxxCloseAllUser ()						' Close all user file handles
		##BLOWBACK = $$TRUE						' so all libraries know blowback is active
		UserBlowback ()								' call Blowback() in user program if one exists
		XxxXstBlowback ()							' Blowback the Standard library (timers)
		XxxXinBlowback ()							' Blowback the Internet/Network library
		XxxXgrBlowback ()							' Blowback the GraphicsDesigner library
		XxxXuiBlowback ()							' Blowback the Guidesigner library
		XxxXntBlowback ()             ' Blowback the compiler (user library blowbacks)
		FreeAliens ()									'
		XxxSetFrameAddr (baseFrameAddr)
		XgrSetCursor (0, 0)						' Restore default cursor
		XgrSetCursorOverride (0, 0)		' Kill override cursor
		##BLOWBACK = $$FALSE
'
'		Reset echo, etc in case blowback interrupted XxxInkey$()
'
'		getattr = 0x402474C0
'		setattr = 0x802474C1
'		x$ = NULL$ (40)
'		xAddr = &x$
'		a = Ioctl (0, getattr, xAddr)
'
'		lflag = 0x0000003B: imin = 4: time = 0
'		XLONGAT (xAddr, 0x000C) = lflag		' ICANON = ON:  ECHO = ON:  etc...
'		UBYTEAT (xAddr, 0x0015) = imin		' MIN  = 4
'		UBYTEAT (xAddr, 0x0016) = time		' TIME = 0
'		a = Ioctl (0, setattr, xAddr)
	END IF
'
	IF environmentActive THEN
		IF ##USERRUNNING THEN ResetDataDisplays (0)
	END IF
'
	##USERRUNNING = $$FALSE			'
	##TRAPVECTOR = 510					' Default trap is normal breakpoint
	blowback = $$FALSE					'
	XitMain (0, 0)							' XitMain never returns here
	XitQuit (0)									' Frames will blow up if RETURN from here
END FUNCTION
'
'
'  #############################
'  #####  UserBlowback ()  #####
'  #############################
'
FUNCTION  UserBlowback ()
	FUNCADDR  func ()
'
	addr = 0
	IFZ addr THEN addr = XxxGetAddressGivenLabel (@"Blowback")
	IFZ addr THEN addr = XxxGetAddressGivenLabel (@"_Blowback")
	IFZ addr THEN addr = XxxGetAddressGivenLabel (@"Blowback@0")
	IFZ addr THEN addr = XxxGetAddressGivenLabel (@"_Blowback@0")
'
'	PRINT "xit.x : UserBlowback() : addr = "; HEX$ (addr, 8)
'
	IF addr THEN
		IF (addr != -1) THEN
			func = addr
			@func ()
		END IF
	END IF
END FUNCTION
'
'
' ########################
' #####  XitQuit ()  #####
' ########################
'
FUNCTION  XitQuit (status)
	SHARED  shmid[]
	SHARED  environmentActive,  textAlteredSinceLastSave,  fileType
	SHARED  editFilename$
'
	IF environmentActive THEN
		IF textAlteredSinceLastSave THEN
			IF (fileType = $$Program) THEN
				message$ = "Quit\nprogram not saved"
			ELSE
				message$ = "Quit\ntext not saved"
			END IF
			warningResponse = WarningResponse (@message$, @" quit ", @" save ")
			SELECT CASE warningResponse
				CASE $$WarningOption	: abort = FileSave ($$FALSE)
																IF abort THEN RETURN
				CASE $$WarningCancel	: RETURN
			END SELECT
		END IF
	END IF
'
	IF shmid[] THEN
		buffer$ = NULL$ (100)
		FOR i = 0 TO UBOUND(shmid[])
			shmid = shmid[i]
			IF (shmid >= 0) THEN
'				reply = SYSTEMCALL (50, 1, shmid, 0, &buffer$)	' Detach Shared Memory
'				IF (reply < 0) THEN PRINT "System refused to deallocate shmid "; shmid
			END IF
		NEXT i
	END IF
'
	XxxXgrQuit ()
	XxxXstFreeLibrary ("", -1)
	addr = ##DYNO0
	size = ##DYNOZ - ##DYNO0
	VirtualFree (addr, size, $$MEM_DECOMMIT)
	addr = ##UCODE0
	size = ##UCODEZ - ##UCODE0
	IF addr THEN VirtualFree (addr, size, $$MEM_DECOMMIT)
	ExitProcess (status)
END FUNCTION
'#incXitDbg
'
'
' ##################################
' #####  MakeUserCodeSpace ()  #####
' ##################################
'
' Win32s refuses VirtualAlloc() of memory below 0x8000000
' VirtualAlloc() says a page cannot be reserved/committed a second time.
'
FUNCTION  MakeUserCodeSpace (theSize)
	STATIC  base,  reserve,  commit
'
	theSize = (theSize + 0x000FFFFF) AND - 0x00100000			' round to 1MB
	newReserve = (theSize + 0x003FFFFF) AND - 0x00400000	' round to 4MB
'
	SELECT CASE TRUE
		CASE (base = 0)								' First pass
			base = 0x40000000						' Start at 1GB
			reserve = newReserve
			commit = theSize
			base = VirtualAlloc (base, reserve, $$MEM_RESERVE, $$PAGE_NOACCESS)
			IFZ base THEN								' 3.1 wants to be on top
				base = (##DYNOZ + 0x10000000) AND 0xF0000000
				base = VirtualAlloc (base, reserve, $$MEM_RESERVE, $$PAGE_NOACCESS)
				IFZ base THEN							' Give up, let 3.1 set base
					base = VirtualAlloc (0, reserve, $$MEM_RESERVE, $$PAGE_NOACCESS)
					IFZ base THEN PRINT "MakeUserCodeSpace() : VirtualAlloc() reserve error": RETURN
				END IF
			END IF
			base		= VirtualAlloc (base, commit, $$MEM_COMMIT, $$PAGE_READWRITE)
			IFZ base THEN PRINT "MakeUserCodeSpace() : VirtualAlloc() commit error" : RETURN
		CASE (newReserve > reserve) || (theSize > reserve)
'
'			VirtualFree() is busted in 3.1 (works in NT).
'
'			PRINT "Freeing old area: "; HEX$(base,8), HEX$(reserve,8), HEX$(commit,8)
'			INLINE$ ("  Press")
			VirtualFree (base, 0, $$MEM_RELEASE)
			base		= base + reserve												' can't reserve twice
			reserve	= newReserve
			commit	= theSize
'			PRINT "New allocation: "; HEX$(base,8), HEX$(reserve,8), HEX$(commit,8)
'			INLINE$ ("  Press")
			base		= VirtualAlloc (base, reserve, $$MEM_RESERVE, $$PAGE_NOACCESS)
			IFZ base THEN								' 3.1 wants to be on top
				base = VirtualAlloc (0, reserve, $$MEM_RESERVE, $$PAGE_NOACCESS)
				IFZ base THEN PRINT "MakeUserCodeSpace() : VirtualAlloc() error": RETURN
			END IF
'			PRINT "Committing "; HEX$(base,8), HEX$(commit,8)
'			INLINE$ ("  Press")
			base		= VirtualAlloc (base, commit, $$MEM_COMMIT, $$PAGE_READWRITE)
			IFZ base THEN PRINT "MakeUserCodeSpace() : VirtualAlloc() error" : RETURN
'			PRINT "MakeUserCodeSpace() : new area "; HEX$(base,8), HEX$(reserve), HEX$(commit,8)

		CASE (theSize > commit)
'			PRINT "New commitment: "; HEX$(base,8), HEX$(reserve,8), HEX$(commit,8), "-> "; HEX$(theSize, 8)
'			INLINE$ ("  Press")
			b = base + commit
			c = theSize - commit
'			PRINT "  "; HEX$(b,8), HEX$(c,8)
			b = VirtualAlloc (b, c, $$MEM_COMMIT, $$PAGE_READWRITE)
			IFZ b THEN PRINT "MakeUserCodeSpace() : VirtualAlloc() error" : RETURN
'			PRINT "  return = "; HEX$(b,8)
			commit = theSize
	END SELECT
'
	##UCODE0 = base
	##UCODE = base + 0x1000			' After 4KB = 1024 function addresses
	##UCODEX = base + 0x1000		' no contents yet
	##UCODEZ = base + commit
	RETURN (base)
END FUNCTION
'#incXitDbg
'
'
' #################################
' #####  DisplayRegisters ()  #####
' #################################
'
FUNCTION  DisplayRegisters ()
	SHARED  EXCEPTION_RECORD  exceptionRecord
'
	reg$ = RegisterString$ ()
	PRINT reg$
	addr = exceptionRecord.exceptionAddress
	IF AddressOk(addr) THEN
		instruction$ = XxxDisassemble$ (addr, $$TRUE)
	END IF
	PRINT " "; HEXX$(addr, 8); ":   "; instruction$
END FUNCTION
'#incXitDbg
'
'
' ######################
' #####  Dump$ ()  #####
' ######################
'
FUNCTION  Dump$ (addr$, xsize$)
	STATIC  nextaddr
'
	ascii$ = NULL$ (16)
	aaddr  = &ascii$
	IF addr$  THEN  addr = XLONG("0x" + addr$) ELSE addr = nextaddr
	IF xsize$ THEN zaddr = addr + XLONG("0x" + xsize$) ELSE zaddr = addr + 0x0100
	addr  =  addr AND 0xFFFFFFFC
	zaddr = zaddr AND 0xFFFFFFFC
'
	DO WHILE (addr < zaddr)
		dump$ = dump$ + HEX$(addr, 8) + ":  "
		xaddr = aaddr
		FOR x = 0 TO 3
			e = UBYTEAT (addr, [0]):											a = e << 24
			IF ((e < 0x20) OR (e > 0x7F)) THEN e = '.'
			UBYTEAT (xaddr, [0]) = e
			e = UBYTEAT (addr, [1]):											a = a OR (e << 16)
			IF ((e < 0x20) OR (e > 0x7F)) THEN e = '.'
			UBYTEAT (xaddr, [1]) = e
			e = UBYTEAT (addr, [2]):											a = a OR (e << 8)
			IF ((e < 0x20) OR (e > 0x7F)) THEN e = '.'
			UBYTEAT (xaddr, [2]) = e
			e = UBYTEAT (addr, [3]):											a = a OR e
			IF ((e < 0x20) OR (e > 0x7F)) THEN e = '.'
			UBYTEAT (xaddr, [3]) = e
'			a = XLONGAT (addr)														' x86 is little endian
			dump$ = dump$ + HEX$(a, 8) + "  "
			addr  =  addr + 4
			xaddr = xaddr + 4
		NEXT x
		dump$ = dump$ + ascii$
		IF (addr < zaddr) THEN dump$ = dump$ + "\n"
	LOOP
	nextaddr = addr
	RETURN (dump$)
END FUNCTION
'#incXitDbg
'
'
' #####################
' #####  Fill ()  #####
' #####################
'
FUNCTION  Fill (addr$, xsize$, value$)
	IF LEN(addr$) THEN addr = XLONG("0x" + addr$) ELSE RETURN (0)
	IF LEN(xsize$) THEN zaddr = addr + XLONG("0x" + xsize$) ELSE zaddr = addr + 0x0100
	value = XLONG("0x" + value$)
	IF (value AND 0xFFFFFF00) THEN RETURN (-1)		' NT is byte fill
	IFZ AddressOk  (addr) THEN RETURN (addr)
	IFZ AddressOk (zaddr) THEN RETURN (zaddr)
	DO WHILE (addr < zaddr)
		UBYTEAT (addr) = value
		INC addr
	LOOP
END FUNCTION
'
'
' ########################
' #####  Frames$ ()  #####
' ########################
'
FUNCTION  Frames$ ()
	frames$ = ""
	frame = XxxGetFrameAddr()
	DO WHILE (frame < ##STACKX)
		funcAddress = XLONGAT(frame,4)				' return address in calling function
		frames$ = frames$ + HEX$(funcAddress,8) + "\r\n"
		frame = XLONGAT(frame)								' calling frame address = [frame]
	LOOP
	RETURN (frames$)
END FUNCTION
'
'
' ###################
' #####  Go ()  #####
' ###################
'
FUNCTION  Go ()
	SHARED  lockOutEnvironment
'
	XxxXBasic ()
	lockOutEnvironment = $$TRUE
END FUNCTION
'#incXitDbg
'
'
' ########################
' #####  Locate$ ()  #####
' ########################
'
FUNCTION  Locate$ (value$)
'
	IF LEN(value$) THEN
		value = XLONG("0x" + value$)
	ELSE
		RETURN ("Locate:  no value given")
	END IF
	addr  = ##DATA0
	zaddr = ##DYNOZ
	found = 0
	DO WHILE (addr < zaddr)
		a = XLONGAT (addr)
		IF (a = value) THEN
			INC found
			IFZ found{3, 0} THEN
				loc1$ = loc1$ + HEX$(addr, 8) + "\n"
			ELSE
				loc1$ = loc1$ + HEX$(addr, 8) + " "
			END IF
		END IF
		addr = addr + 4
	LOOP
'
	addr  = ##UCODE0
	zaddr = ##UCODEZ
	found = 0
	DO WHILE (addr < zaddr)
		a = XLONGAT (addr)
		IF (a = value) THEN
			INC found
			IFZ found{3, 0} THEN
				loc2$ = loc2$ + HEX$(addr, 8) + "\n"
			ELSE
				loc2$ = loc2$ + HEX$(addr, 8) + " "
			END IF
		END IF
		addr = addr + 4
	LOOP
'
	addr  = ##STACK0
	zaddr = ##STACKZ
	found = 0
	DO WHILE (addr < zaddr)
		a = XLONGAT (addr)
		IF (a = value) THEN
			INC found
			IFZ found{3, 0} THEN
				loc3$ = loc3$ + HEX$(addr, 8) + "\n"
			ELSE
				loc3$ = loc3$ + HEX$(addr, 8) + " "
			END IF
		END IF
		addr = addr + 4
	LOOP
'
	locate$ = loc1$
	IF loc2$ THEN
		IF locate$ THEN
			rightChar = locate${UBOUND(locate$)}
			IF (rightChar != 10) THEN locate$ = locate$ + "\n"
			locate$ = locate$ + loc2$
		ELSE
			locate$ = loc2$
		END IF
	END IF
	IF loc3$ THEN
		IF locate$ THEN
			rightChar = locate${UBOUND(locate$)}
			IF (rightChar != 10) THEN locate$ = locate$ + "\n"
			locate$ = locate$ + loc3$
		ELSE
			locate$ = loc3$
		END IF
	END IF
	RETURN (locate$)
END FUNCTION
'#incXitDbg
'
'
' ###########################
' #####  MemoryMap$ ()  #####
' ###########################
'
FUNCTION  MemoryMap$ ()
'
	##STACK		= XxxGetFrameAddr()
	##STACK0	= ##STACK AND 0xFFFFF000
'
	m1$ = "SECTION   PAGE BASE   LOW ADDR    HIGH ADDR   NEXT PAGE\n"
	m2$ = "  CODE    " + HEX$(##CODE0, 8)  + "    " + HEX$(##CODE, 8)  + "    " + HEX$(##CODEX, 8)  + "    " + HEX$(##CODEZ, 8) + "\n"
	m3$ = "   BSS    " + HEX$(##BSS0, 8)   + "    " + HEX$(##BSS, 8)   + "    " + HEX$(##BSSX, 8)   + "    " + HEX$(##BSSZ, 8)   + "\n"
	m4$ = "  DATA    " + HEX$(##DATA0, 8)  + "    " + HEX$(##DATA, 8)  + "    " + HEX$(##DATAX, 8)  + "    " + HEX$(##DATAZ, 8) + "\n"
	m5$ = "  DYNO    " + HEX$(##DYNO0, 8)  + "    " + HEX$(##DYNO, 8)  + "    " + HEX$(##DYNOX, 8)  + "    " + HEX$(##DYNOZ, 8) + "\n"
	m6$ = " UCODE    " + HEX$(##UCODE0, 8) + "    " + HEX$(##UCODE, 8) + "    " + HEX$(##UCODEX, 8) + "    " + HEX$(##UCODEZ, 8) + "\n"
	m7$ = " STACK    " + HEX$(##STACK0, 8) + "    " + HEX$(##STACK, 8) + "    " + HEX$(##STACKX, 8) + "    " + HEX$(##STACKZ, 8)
	RETURN (m1$ + m2$ + m3$ + m4$ + m5$ + m6$ + m7$)
END FUNCTION
'#incXitDbg
'#incXitStd
'
'
' #########################
' #####  SetAlarm ()  #####
' #########################
'
'	UNUSED IN NT
'
'	Input:  milliseconds
'					0								DISABLES timer
'
'	Discussion:
'		88k:		88k Alarm is not accurate:  1 second per interupt --> 2% slow
'																				.25 sec								--> 9% slow
'						OPUS granularity is .016667 sec (60ths)
'						BCS does NOT require platforms to have subsecond granularity...
'
'		NT:
'			NT does not have an ALARM signal.  It recommends the use of the
'				TimerProc() functions which DOESN'T WORK UNLESS THE SYSTEM QUEUE
'				IS BEING PROCESSED (regardless of whether using queued event or
'				Callback function).  PDE needs a time event which interrupts
'				the task, it CANNOT use a queue based time event (eg application
'				hangs (x: GOTO x)--queue will never be examined.)
'			The alternative is the TimeProc() functions.  NT is very restrictive
'				about their use:  the only functions that can be called from it are:
'					PostMessage(), timeGetSystemTime(), timeGetTime(),
'					timeSetEvent(), timeKillEvent(),
'					midiOutShortMsg(), midOutLongMsg()
'			I assume the problems implied are interrupting allocation or Win32
'				activities.  All calls to Win32 functions set ##LOCKOUT.
'				The TimeProc() will not process the queue when ##LOCKOUT is set,
'					or when the interrupted address is in an allocation area.
'			Try something else if this doesn't work.
'
'	Return:		0  OK
'						-1 if microsecond range invalid
'
FUNCTION  SetAlarm (millisec)
	STATIC  alarmID
'
'	$TIME_ONESHOT		= 0
'	$TIME_PERIODIC	= 1
'
'	IF alarmID THEN
'		timeKillEvent(alarmID)
'		alarmID = 0
'	END IF
'	IFZ millisec THEN RETURN
'
'	alarmID = timeSetEvent(millisec, millisec >> 1, &XxxAlarmHandler(), 0, $TIME_PERIODIC)
END FUNCTION
'#incXitDbg
'
'
' ###########################
' #####  Substitute ()  #####
' ###########################
'
FUNCTION  Substitute (addr)
'
	DO
		IFZ AddressOk (addr) THEN PRINT MemoryMap$() : RETURN (addr)
		a = XLONGAT (addr)
		PRINT HEX$(addr, 8); ":  "; HEX$(a, 8);
		x$ = INLINE$(" >> ")
'
		SELECT CASE x$
			CASE "q" :  RETURN (0)
			CASE "*" :  addr = a:         DO LOOP
			CASE "-" :  addr = addr - a:  DO LOOP
			CASE "+" :  addr = addr + a:  DO LOOP
			CASE "." :  addr = addr - 4:  DO LOOP
			CASE "":    addr = addr + 4:  DO LOOP
		END SELECT
'
		lc = x${0}
		IF (((lc >= '0') AND (lc <= '9')) || ((lc >= 'A') AND (lc <= 'F')) || ((lc >= 'a') AND (lc <= 'f'))) THEN
			value = XLONG("0x"+x$)
			IF ((addr >= ##CODE0) AND (addr <= ##CODEZ)) THEN
				PRINT "Can't write Xit code area"
			ELSE
				XLONGAT (addr) = value
				addr = addr + 4
			END IF
		END IF
	LOOP
END FUNCTION
'
'
' #######################
' #####  UserGo ()  #####
' #######################
'
'	Entry assumes ##USERRUNNING = $$FALSE and ##SIGNALACTIVE = $$FALSE
' Entry assumes compilation is up to date
'
FUNCTION  UserGo ()
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  environmentActive
	SHARED  editFunction
	SHARED  sigNumber
	SHARED  defaultDirectory$
	SHARED  userGoFrame
	SHARED  huh
'
	IF huh THEN PRINT "ug0";
	XstChangeDirectory (@defaultDirectory$)			' reset to entry directory
	IF huh THEN PRINT "ug1";
	' Initialize USER libraries
	XxxXntInitLibraries()
'	XxxLibraryInitialize ()											' initialize libraries
'
	BreakProgrammer ($$BreakInstallAll, 0, 0)
	IF huh THEN PRINT "ug2";
'	MakeUserCodeRX()													' NT: Not required
'
	IF huh THEN PRINT "ug3";
	userGoFrame = XxxGetFrameAddr()
	IF huh THEN PRINT "ug4";
'	PRINT "UserGo() : Frame Address = "; HEX$(userGoFrame, 8)
'	PRINT "UserGo() : Go to user program"
'
	IF huh THEN PRINT "ug5";
	##USERRUNNING = $$TRUE
	IF environmentActive THEN
		IF huh THEN PRINT "ug6";
		SetCurrentStatus ($$StatusRunning, 0)
		IF huh THEN PRINT "ug7";
		ResetDataDisplays ($$InitiatingRun)
		IF huh THEN PRINT "ug8";
		##LOCKOUT = $$FALSE
	END IF
	' Reset Xgr User-mode variables
	XgrResetUserMode()
'
	sigNumber = 0
	IF huh THEN PRINT "ug9";
'
'	Enable the Alarm to handle event dispatches
'	SetAlarm (100)								' Preset alarm (UNUSED IN NT)
	IF huh THEN PRINT "ugA";
	ClearRegisters ()							' Clear ##REG[], ##ALARMREG[]
	IF huh THEN PRINT "ugB";
	##TRAPVECTOR = 510						' Default trap is normal breakpoint
'																' ********************************
	IF huh THEN PRINT "ugC";
	XxxG ()												' *****  GO TO USER PROGRAM  *****
'																' ********************************
	##WHOMASK = 0									' System whomask
	IF huh THEN PRINT "ugD";
	XgrSetCursor (0, 0)						' Restore default cursor
	IF huh THEN PRINT "ugE";
	XgrSetCursorOverride (0, 0)		' Kill override cursor
	IF huh THEN PRINT "ugF";
'
'	Disable the Alarm
'	SetAlarm (0)									' Not called in NT
	IF huh THEN PRINT "ugG";
	ClearRegisters ()
	IF huh THEN PRINT "ugH";
	##USERRUNNING = $$FALSE
'
'	PRINT "UserGo() : Frame Address = "; HEX$(XxxGetFrameAddr(), 8)
'	PRINT "UserGo() : Back from user program"
'	MakeUserCodeRW()																' NT: Not required
'
	IF huh THEN PRINT "ugI";
	BreakPatch()
	IF huh THEN PRINT "ugJ";
	BreakInternal ($$BreakRemoveAll, 0, 0, 0)
	IF huh THEN PRINT "ugK";
'
	XxxCloseAllUser ()															' Close all user file handles
'
	IF huh THEN PRINT "ugL";
	IF environmentActive THEN
		IF huh THEN PRINT "ugM";
		ResetDataDisplays (0)					' assy still ok
		IF huh THEN PRINT "ugN";
		UserBlowback ()								' call Blowback() in user program if one exists
		IF huh THEN PRINT "ugO";
		XxxXstBlowback ()							' blowback USER standard library (timers)
		IF huh THEN PRINT "ugP";
		XxxXinBlowback ()							' Blowback the Internet/Network library
		IF huh THEN PRINT "ugQ";
 		XxxXgrBlowback ()							' blowback USER GraphicsDesigner data
		IF huh THEN PRINT "ugR";
		XxxXuiBlowback ()							' blowback USER GuiDesigner data
		IF huh THEN PRINT "ugS";
		XxxXntBlowback ()             ' blowback USER libraries (call Blowback() in user DLLs)
		IF huh THEN PRINT "ugT";
		FreeAliens ()
		IF huh THEN PRINT "ugU";
		ClearRuntimeError ()
		IF huh THEN PRINT "ugV";
	END IF
	IF huh THEN PRINT "ugZ";
END FUNCTION
'#incXitDbg
'
'
' ##########################
' #####  AddressOk ()  #####
' ##########################
'
FUNCTION  AddressOk (addr)
'
	##STACK		= XxxGetFrameAddr()
	##STACK0	= ##STACK AND 0xFFFFF000
'
	IF ((addr >= ##CODE0)  AND (addr < ##CODEZ))  THEN RETURN (##CODEZ)
	IF ((addr >= ##UCODE0) AND (addr < ##UCODEZ)) THEN RETURN (##UCODEZ)
	IF ((addr >= ##DATA0)  AND (addr < ##DATAZ))  THEN RETURN (##DATAZ)
	IF ((addr >= ##DYNO0)  AND (addr < ##DYNOZ))  THEN RETURN (##DYNOZ)
	IF ((addr >= ##BSS0)   AND (addr < ##BSSZ))   THEN RETURN (##BSSZ)
	IF ((addr >= ##STACK0) AND (addr < ##STACKZ)) THEN RETURN (##STACKZ)
	RETURN ($$FALSE)
END FUNCTION
'#incXitDbg
'
'
' ###############################
' #####  ChangeRegister ()  #####
' ###############################
'
FUNCTION  ChangeRegister (reg[], arg0$, arg1$)
'
	arg0$ = LCLIP$(arg0$, 1)
	IF arg0$ THEN arg0  = XLONG(arg0$) ELSE PRINT "Bad register spec": RETURN
	IF arg1$ THEN arg1  = XLONG("0x" + arg1$) ELSE PRINT "Need value": RETURN
	IF (arg0 > 31) THEN PRINT "Bad register spec": RETURN
	IF (arg0 <  0) THEN PRINT "Bad register spec": RETURN
	reg[arg0] = arg1
END FUNCTION
'#incXitDbg
'
'
' ###############################
' #####  ClearRegisters ()  #####
' ###############################
'
FUNCTION  ClearRegisters ()
	DO WHILE (i < 40)
'		##REG[i] = 0
'		##ALARMREG[i] = 0
		INC i
	LOOP
END FUNCTION
'#incXitDbg
'
'
' ###########################
' #####  ParseLine$ ()  #####
' ###########################
'
FUNCTION  ParseLine$ (theLine$, a$[])
'
	a$[0] = ""
	a$[1] = ""
	a$[2] = ""
	a$[3] = ""
	a$[4] = ""
	a$[5] = ""
	a$[6] = ""
'
	IFZ theLine$ THEN RETURN ("")
	arg = 0
	DO
		a = INSTR(theLine$, " ", 1)
		IF a THEN
			a$[arg] = LEFT$(theLine$, a-1)
			theLine$ = LTRIM$(MID$(theLine$, a+1))
		ELSE
			a$[arg] = theLine$
			RETURN (a$[0])
		END IF
		INC arg
	LOOP UNTIL (arg > 6)
	RETURN (a$[0])
END FUNCTION
'#incXitDbg
'
'
' ################################
' #####  RegisterString$ ()  #####
' ################################
'
FUNCTION  RegisterString$ ()
	SHARED  EXCEPTION_CONTEXT  exceptionContext
'
	whomask = ##WHOMASK
	##WHOMASK = 0
	DIM reg$[3]
'
	reg$[0] = " eax: " + HEX$(exceptionContext.eax,8) + "  edi: " + HEX$(exceptionContext.edi,8) + "  eip: " + HEX$(exceptionContext.eip,8)    + "   es: " + HEX$(exceptionContext.segEs,8)
	reg$[1] = " ebx: " + HEX$(exceptionContext.ebx,8) + "  esi: " + HEX$(exceptionContext.esi,8) + "  flg: " + HEX$(exceptionContext.eFlags,8) + "   fs: " + HEX$(exceptionContext.segFs,8)
	reg$[2] = " ecx: " + HEX$(exceptionContext.ecx,8) + "  ebp: " + HEX$(exceptionContext.ebp,8) + "   cs: " + HEX$(exceptionContext.segCs,8)  + "   gs: " + HEX$(exceptionContext.segGs,8)
	reg$[3] = " edx: " + HEX$(exceptionContext.edx,8) + "  esp: " + HEX$(exceptionContext.esp,8) + "   ds: " + HEX$(exceptionContext.segDs,8)  + "   ss: " + HEX$(exceptionContext.segSs,8)
'
	XstStringArrayToString (@reg$[], @reg$)
	##WHOMASK = whomask
	RETURN (reg$)
END FUNCTION
'
'
' #############################
' #####  CountHeaders ()  #####
' #############################
'
FUNCTION  CountHeaders ()
	STATIC  freeChunks[],  freeBins[]
'
	IFZ freeChunks[] THEN
		DIM freeChunks[16]
'		DIM freeBins[255,4]
	END IF
'
	FOR i = 0 TO 16
		freeChunks[i] = 0
	NEXT i
'
'	FOR i = 0 TO 255
'		FOR j = 0 TO 4
'			freeBins[i,j] = 0
'		NEXT j
'	NEXT i
'	iFree = 0

	first		= ##DYNO0
	addr		= first
	count		= 0:  totalSize		= 0
	free		= 0:  freeSize		= 0
	raw			= 0:  rawSize			= 0
	whoraw	= 0:  whorawSize	= 0
	user		= 0:  userSize		= 0
	norm		= 0:  normSize		= 0
	up			= XLONGAT (addr)
'
	DO WHILE (up)
		INC count
		blockLength = XLONGAT (addr)
		totalSize = totalSize + blockLength
		word1 = XLONGAT (addr, [1])
		word3	= XLONGAT (addr, [3])
		SELECT CASE TRUE
			CASE !(word1 AND 0x80000000)
					INC free
					freeSize = freeSize + blockLength
					i = blockLength - 0x20
					IF (i < 0) THEN i = 0
					i = i >> 4
					IF (i > 16) THEN i = 16
					INC freeChunks[i]
'					IF (i = 16) THEN
'						IF (iFree < 256) THEN
'							freeBins[iFree,0] = addr
'							freeBins[iFree,1] = XLONGAT(addr)
'							freeBins[iFree,2] = word1
'							freeBins[iFree,3] = XLONGAT(addr, [2])
'							freeBins[iFree,4] = word3
'							INC iFree
'						END IF
'					END IF
			CASE (word3 = 0x80000001)
					INC raw
					rawSize = rawSize + blockLength
			CASE (word3 = 0x00000001)
					INC raw
					rawSize = rawSize + blockLength
			CASE (word3 = 0x81000001)
					INC whoraw
					whorawSize = whorawSize + blockLength
			CASE (word3 = 0x01000001)
					INC whoraw
					whorawSize = whorawSize + blockLength
			CASE (word3 AND 0x01000000)
					INC user
					userSize = userSize + blockLength
			CASE ELSE
					INC norm
					normSize = normSize + blockLength
		END SELECT
		addr	= addr + up
		up		= XLONGAT (addr)
	LOOP
'
	whorawSize = whorawSize >> 10
	userSize = userSize >> 10
	freeSize = freeSize >> 10
	rawSize = rawSize >> 10
	normSize = normSize >> 10
	totalSize = totalSize >> 10
'
'	PRINT
'	IF iFree THEN
'		DEC iFree
'		a$ = "Free headers in bin 17:\n"
'		FOR i = 0 TO iFree
'			a$ = a$ + "  " + STRING$(i) + ")  " + HEX$(freeBins[i,0],8) + ":"
'			FOR j = 1 TO 4
'				a$ = a$ + "  " + HEX$(freeBins[i,j],8)
'			NEXT j
'			a$ = a$ + "\n"
'		NEXT i
'		PRINT a$
'	END IF
'
	PRINT "whoraw = "; whoraw;	TAB(18); whorawSize; " Kb"
	PRINT "user   = "; user;		TAB(18); userSize
	PRINT "free   = "; free;		TAB(18); freeSize,,
	free$ = "  "
	FOR i = 0 TO 16
		free$ = free$ + STR$(freeChunks[i])
	NEXT i
	PRINT free$
	PRINT "raw    = "; raw;			TAB(18); rawSize
	PRINT "norm   = "; norm;		TAB(18); normSize
	PRINT "TOTAL  = "; count;		TAB(18); totalSize
END FUNCTION
'#incXitDbg
'
'
' ########################
' #####  Headers ()  #####
' ########################
'
FUNCTION  Headers (dpoint, headaddr)
'
	FOR i = 0 TO 3
		a = XLONGAT (dpoint, 0x0000)
		b = XLONGAT (dpoint, 0x0004)
		c = XLONGAT (dpoint, 0x0008)
		d = XLONGAT (dpoint, 0x000C)
		PRINT   HEX$(dpoint, 8); ":  ";
		PRINT   HEX$(a, 8); "  "; HEX$(b, 8); "  "; HEX$(c, 8); "  "; HEX$(d, 8)
		dpoint = dpoint + 0x0010
	NEXT i
	a = XLONGAT (dpoint)
	PRINT     HEX$(dpoint, 8); ":  ";
	PRINT     HEX$(a, 8)
	DO
		a = XLONGAT (headaddr, 0x0000)
		b = XLONGAT (headaddr, 0x0004)
		c = XLONGAT (headaddr, 0x0008)
		d = XLONGAT (headaddr, 0x000C)
		PRINT HEX$(headaddr, 8); ":  ";
		PRINT HEX$(a, 8); "  "; HEX$(b, 8); "  "; HEX$(c, 8); "  "; HEX$(d, 8)
		headaddr = headaddr + a
	LOOP WHILE a
END FUNCTION
'#incXitDbg
'
'
' ##############################
' #####  MissingHeader ()  #####
' ##############################
'
FUNCTION  MissingHeader (addr, heads[], limit)
'
	DO
		IF heads[a] = addr THEN RETURN (0)
		INC a
	LOOP UNTIL (a > limit)
	RETURN ($$TRUE)
END FUNCTION
'#incXitDbg
'
'
' ############################
' #####  PrintHeader ()  #####
' ############################
'
FUNCTION  PrintHeader (addr, ua, da, ul, dl)
	PRINT HEX$(addr, 8); ":  "; HEX$(ua,  8);  "  ";  HEX$(da,  8); "  "; HEX$(ul,  8); "  "; HEX$(dl,  8)
END FUNCTION
'#incXitDbg
'
'
' ############################
' #####  TestHeaders ()  #####
' ############################
'
FUNCTION  TestHeaders ()
	SHARED  tempo[],  heads[],  teston,  testdibs
	STATIC  uhead,  firstentry
'
	IFZ teston THEN RETURN
	IF testdibs THEN RETURN
	testdibs = $$TRUE
'
	IFZ firstentry THEN
		uhead = UBOUND(heads[])
		firstentry = $$TRUE
	END IF
'
	headaddr = ##DYNO
	header = 0
'
	DO
		upLink = XLONGAT (headaddr)
		headaddr = headaddr + upLink
		IF (headaddr < ##DYNO) THEN
			GOSUB PrintHeader
			GOSUB PrintTable
			PRINT "Uplink corrupted..."
			testdibs = $$FALSE
			RETURN
		END IF
		IF (headaddr > ##DYNOZ) THEN
			GOSUB PrintHeader
			GOSUB PrintTable
			PRINT "Uplink corrupted..."
			testdibs = $$FALSE
			RETURN
		END IF
		INC header
		IFZ upLink THEN EXIT DO
	LOOP
'
	IF (uhead < header+1) THEN
		DIM heads[header+4]
	END IF
	headaddr = ##DYNO
	header = 0
'
	DO
		upLink = XLONGAT (headaddr)
		heads[header] = headaddr
		headaddr = headaddr + upLink
		INC header
		IFZ upLink THEN EXIT DO
	LOOP
	count = header - 1
'
	FOR entry = 0 TO count
		headaddr = heads[entry]												' address of M
		upAddr		= XLONGAT (headaddr, [0])						' word 0 of M
		adownAddr	= XLONGAT (headaddr, [1])						' word 1 of M
		upLink		= XLONGAT (headaddr, [2])						' word 2 of M
		downLink	= XLONGAT (headaddr, [3])						' word 3 of M
		downAddr	= adownAddr AND 0x7FFFFFFF					' remove allocated bit
		table = (upAddr - 0x20) >> 4									' table# of M
		IF (table > 16) THEN table = 16
		tableAddr = XLONGAT (##DATA, [table])					' tableAddr of M
'
		IF upAddr THEN
			upper = headaddr + upAddr										' address of H
			upAddrx			= XLONGAT (upper, [0])					' word 0 of H
			adownAddrx	= XLONGAT (upper, [1])					' word 1 of H
			upLinkx			= XLONGAT (upper, [2])					' word 2 of H
			downLinkx		= XLONGAT (upper, [3])					' word 3 of H
			downAddrx		= adownAddrx AND 0x7FFFFFFF			' remove allocated bit
			IF upAddrx THEN
				xupper = upper + upAddrx									' address of HH
				xupAddrx		= XLONGAT (xupper, [0])				' word 0 of HH
				axdownAddrx	= XLONGAT (xupper, [1])				' word 1 of HH
				xupLinkx		= XLONGAT (xupper, [2])				' word 2 of HH
				xdownLinkx	= XLONGAT (xupper, [3])				' word 3 of HH
				xdownAddrx	= axdownAddrx AND 0x7FFFFFFF			' remove allocated bit
			END IF
			IF (upAddr != downAddrx) THEN
				ha	= headaddr
				ua	= upAddr
				da	= adownAddr
				ul	= upLink
				dl	= downLink
				up	= upper
				uax	= upAddrx
				dax	= adownAddrx
				ulx	= upLinkx
				dlx	= downLinkx
				PRINT
				PrintHeader (ha, ua, da, ul, dl)
				PrintHeader (up, uax, dax, ulx, dlx)
				PRINT "*****  This addr-upLink != next addr-downlink  *****"
				testdibs = $$FALSE
				RETURN
			END IF
			IF (adownAddr >= 0) AND (adownAddrx >= 0) THEN
				ha	= headaddr
				ua	= upAddr
				da	= adownAddr
				ul	= upLink
				dl	= downLink
				up	= upper
				uax	= upAddrx
				dax	= adownAddrx
				ulx	= upLinkx
				dlx	= downLinkx
				xup	= xupper
				xua	= xupAddrx
				xda	= axdownAddrx
				xul	= xupLinkx
				xdl	= xdownLinkx
				GOSUB PrintTable
				PrintHeader (ha, ua, da, ul, dl)
				PrintHeader (up, uax, dax, ulx, dlx)
				PrintHeader (xup, xua, xda, xul, xdl)
				PRINT "*****  Two free chunks in a row"
				testdibs = $$FALSE
				RETURN
			END IF
		END IF
		IFZ downLink THEN
			IF (headaddr != tableAddr) THEN
				ha	= headaddr
				ua	= upAddr
				da	= adownAddr
				ul	= upLink
				dl	= downLink
				PRINT
				PRINT "Table Pointer #"; table; " = "; HEX$(tableAddr, 8)
				PrintHeader (ha, ua, da, ul, dl)
				PRINT "*****  Size downLink = 0, but table pointer doesn't point here"
				testdibs = $$FALSE
				RETURN
			END IF
		END IF
		IF (adownAddr >= 0) AND (downLink > 0) THEN
			SUinSD = XLONGAT (downLink, [2])
			IF (SUinSD != headaddr) THEN
				ha	= headaddr
				ua	= upAddr
				da	= adownAddr
				ul	= upLink
				dl	= downLink
				PRINT
				PrintHeader (ha, ua, da, ul, dl)
				PRINT "*****  SU addr in SD header doesn't point here  *****"
				testdibs = $$FALSE
				RETURN
			END IF
		END IF
		IF (adownAddr >= 0) AND (upLink > 0) THEN
			SDinSU = XLONGAT (upLink, [3])
			IF (SDinSU != headaddr) THEN
				ha	= headaddr
				ua	= upAddr
				da	= adownAddr
				ul	= upLink
				dl	= downLink
				PRINT
				PrintHeader (ha, ua, da, ul, dl)
				PRINT "*****  SD addr in SU header doesn't point here  *****"
				testdibs = $$FALSE
				RETURN
			END IF
		END IF
		IF (adownAddr > 0) AND (downLink > 0) THEN
			IF (MissingHeader(downLink, @heads[], count)) THEN
				ha	= headaddr
				ua	= upAddr
				da	= adownAddr
				ul	= upLink
				dl	= downLink
				xha	= downLink
				xua	= XLONGAT (xha, [0])
				xda	= XLONGAT (xha, [1])
				xul	= XLONGAT (xha, [2])
				xdl	= XLONGAT (xha, [3])
				PRINT
				PrintHeader ( ha,  ua,  da,  ul,  dl)
				PrintHeader (xha, xua, xda, xul, xdl)
				PRINT "*****  SD addr points to invalid/nonexistent header  *****"
				testdibs = $$FALSE
				RETURN
			END IF
		END IF
		IF (adownAddr > 0) AND (upLink > 0) THEN
			IF (MissingHeader(upLink, @heads[], count)) THEN
				ha	= headaddr
				ua	= upAddr
				da	= adownAddr
				ul	= upLink
				dl	= downLink
				xha	= upLink
				xua	= XLONGAT (xha, [0])
				xda	= XLONGAT (xha, [1])
				xul	= XLONGAT (xha, [2])
				xdl	= XLONGAT (xha, [3])
				PRINT
				PrintHeader ( ha,  ua,  da,  ul,  dl)
				PrintHeader (xha, xua, xda, xul, xdl)
				PRINT "*****  SU addr points to invalid/nonexistent header  *****"
				testdibs = $$FALSE
				RETURN
			END IF
		END IF
		IFZ upAddr THEN EXIT FOR
	NEXT entry
	testdibs = $$FALSE
	PRINT "***** "; header; " headers"
'	PRINT "*****  DONE  *****"
	RETURN
'
' *****  SUBROUTINES  *****
'
SUB PrintHeader
	aaa = headaddr
'	PRINT HEX$ (aaa, 8); ":  "
	bbb = XLONGAT (headaddr, [0])
	ccc = XLONGAT (headaddr, [1])
	ddd = XLONGAT (headaddr, [2])
	eee = XLONGAT (headaddr, [3])
	PRINT HEX$ (aaa, 8); ":  "
	PRINT HEX$ (bbb, 8);;;
	PRINT HEX$ (ccc, 8);;;
	PRINT HEX$ (ddd, 8);;;
	PRINT HEX$ (eee, 8)
END SUB
'
SUB PrintTable
	FOR i = 0 TO 16
		tempo[i] = XLONGAT (##DATA, [i])
	NEXT i
	FOR i = 0 TO 16
		PRINT HEX$ (tempo[i], 8);;;
		IF ( i{2,0} = 3 ) THEN PRINT
	NEXT i
	PRINT
END SUB
END FUNCTION
'
'
' ##################################
' #####  BreakContinuePrep ()  #####
' ##################################
'
'	BreakContinuePrep() sets up the exceptionRecord.exceptionAddress so program
'		execution will continue at "continueAddr" when the top-level function
'		in Xit returns.  It puts the original opcode back at "continueAddr",
'		inspects the opcode to see what kind it is, and on this basis installs
'		breakpoints where required to break program execution after a single
'		instruction.  It logs the addresses and opcodes of these break patches
'		in breakPatchAddr[] and breakPatchCode[], as well as "continueAddr"
'		and the breakpoint opcode that was originally there.
'
FUNCTION  BreakContinuePrep (command, func, continueAddr)
	SHARED  xitGrid
	SHARED  EXCEPTION_RECORD   exceptionRecord
	SHARED  EXCEPTION_CONTEXT  exceptionContext
'
	IF continueAddr THEN									' no changes if 0
		SXIP = continueAddr									' address at which to continue execution
		exceptionContext.eip = SXIP
	ELSE
		SXIP = exceptionContext.eip
	END IF
'
'	PRINT "BreakContinuePrep:"
'	PRINT "  SXIP = "; HEX$(SXIP, 8); ":  "; XxxDisassemble$ (SXIP, $$TRUE)
'
	startAddr = SXIP
	BreakProgrammer ($$BreakInstallAll, 0, 0)
'
	SELECT CASE command
		CASE $$BreakContinueRunning
		CASE $$BreakContinueToCursor
					XuiSendMessage (xitGrid, #GetTextCursor, 0, @line, 0, 0, $$xitTextLower, 0)
					BreakInternal ($$BreakInstallOne, func, line, 0)
		CASE $$BreakContinueStepLocal
					BreakInternal ($$BreakInstallFunc, func, 0, 0)
		CASE $$BreakContinueStepGlobal
					BreakInternal ($$BreakInstallAll, 0, 0, 0)
		CASE ELSE
					PRINT "Bad command to BreakContinuePrep()"
	END SELECT
'
	IFZ #WINLESS THEN
		breakCode	= UBYTEAT (startAddr)		' NT 1 byte
		break			= $$BREAK1
'		PRINT "  Break @SXIP = "; HEXX$(breakCode, 2)
	ELSE
		breakCode	= USHORTAT (startAddr)	' NT 2 byte
		break			= $$BREAK2
'		PRINT "  Break @SXIP = "; HEXX$(breakCode, 4)
	END IF
'
	IF (breakCode != break) THEN RETURN			' no BP at startAddr to patch
'
'
'	Breakpoint at the address we want to start executing
'
	BreakProgrammer ($$BreakRemoveOne, startAddr, 0)
'
	IFZ #WINLESS THEN
		breakTest = UBYTEAT (startAddr)				' NT 1 byte
	ELSE
		breakTest = USHORTAT (startAddr)			' NT 2 byte
	END IF
'
	IF (breakTest = break) THEN
		opcode = BreakInternal ($$BreakGetFuncLineOpcode, 0, 0, startAddr)
		IF (opcode < 0) THEN
			PRINT "  Can't find breakpoint in Internal Arrays either !!!"
			PRINT "  Can't find opcode to overwrite breakpoint at "; HEX$(startAddr, 8)
			PRINT "  This is death... bombing out of BreakContinuePrep()"
			RETURN
		ELSE
			IFZ #WINLESS THEN
				UBYTEAT (startAddr) = opcode			' NT 1 byte
			ELSE
				USHORTAT (startAddr) = opcode			' NT 2 byte
			END IF
		END IF
	ELSE
		opcode = breakTest
'		PRINT "  Good!  BreakProgrammer removed breakpoint at SXIP = "; HEX$(startAddr, 8); " ("; HEX$(opcode, 2); ")"
	END IF
'
	IFZ #WINLESS THEN
		BreakPatchLog (startAddr, $$BREAK1)		' log $$BREAK patch at this address
	ELSE
		BreakPatchLog (startAddr, $$BREAK2)		' log $$BREAK patch at this address
	END IF
'
	BreakPatchAll (startAddr)
END FUNCTION
'#incXitDbg
'
'
' ###########################
' #####  BreakPatch ()  #####
' ###########################
'
'	For all non-zero entries in breakPatchAddr[], install the opcode in
'		breakPatchCode[] into memory at the address in breakPatchAddr[].
'
FUNCTION  BreakPatch ()
	SHARED  breakPatchAddr[]
	SHARED  breakPatchCode[]
'
	foundPatches = 0
	upatch = UBOUND(breakPatchAddr[])
	i = 0
	DO UNTIL (i > upatch)
		patchAddr = breakPatchAddr[i]
		IF patchAddr THEN
			INC foundPatches
			patchCode = breakPatchCode[i]				' get original opcode and...
'
			IFZ #WINLESS THEN
				breakCode = UBYTEAT(patchAddr)		' NT 1 byte
			ELSE
				breakCode = USHORTAT(patchAddr)		' NT 2 byte
			END IF
'
			IFZ #WINLESS THEN
				UBYTEAT (patchAddr) = patchCode		' NT 1 byte
			ELSE
				USHORTAT (patchAddr) = patchCode	' NT 2 byte
			END IF
			breakPatchAddr[i] = 0								' this patch breakpoint is removed
			breakPatchCode[i] = 0								' ditto
		END IF
		INC i
	LOOP
	RETURN (foundPatches)
END FUNCTION
'#incXitDbg
'
'
' ##############################
' #####  BreakPatchAll ()  #####
' ##############################
'
' Install patch breakpoint over 1st opcode of every source line
'   not currently holding a breakpoint (skip startAddr)
'
FUNCTION  BreakPatchAll (startAddr)
	EXTERNAL  /xxx/  maxFuncNumber
	SHARED  prog[]
	SHARED  lineAddr[]
	SHARED  lineLast[]
	SHARED  breakPatchAddr[]
	SHARED  breakPatchCode[]
'
	i = 0
	uBreak = UBOUND(breakPatchAddr[])
'
	func = 1																' No breakpoints in PROLOG
	DO UNTIL (func > maxFuncNumber)
		IFZ prog[func,] THEN INC func: DO DO
		lineAddr = lineAddr[func, 0]
		lineLast = lineLast[func]
		line = 0
		firstLine = $$TRUE
		DO UNTIL (line > lineLast)
			nextAddr = lineAddr[func, line + 1]
			IF (lineAddr < nextAddr) THEN					' Skip blank lines/comments
				IF firstLine THEN										' No func line breakpoints
					firstLine = $$FALSE
				ELSE
					IFZ #WINLESS THEN
						opcode = UBYTEAT(lineAddr)			' NT 1 byte
						break = $$BREAK1
					ELSE
						opcode = USHORTAT(lineAddr)			' NT 2 byte
						break = $$BREAK2
					END IF
					IF (opcode != break) THEN
						IF (lineAddr != startAddr)
							GOSUB BreakPatchLog
							IFZ #WINLESS THEN
								UBYTEAT (lineAddr) = $$BREAK1		' NT 1 byte
							ELSE
								USHORTAT (lineAddr) = $$BREAK2	' NT 2 byte
							END IF
						END IF
					END IF
				END IF
			END IF
			lineAddr = nextAddr
			INC line
		LOOP
		INC func
	LOOP
	RETURN
'
' *****  BreakPatchLog  *****
'
SUB BreakPatchLog
	DO WHILE (breakPatchAddr[i])
		INC i
	LOOP WHILE (i <= uBreak)
	IF (i > uBreak) THEN
		uBreak = (uBreak + (uBreak >> 1)) OR 15
		REDIM breakPatchAddr[uBreak]
		REDIM breakPatchCode[uBreak]
	END IF
	breakPatchAddr[i] = lineAddr
	breakPatchCode[i] = opcode
END SUB
END FUNCTION
'#incXitDbg
'
'
' ##############################
' #####  BreakPatchLog ()  #####
' ##############################
'
FUNCTION  BreakPatchLog (breakAddr, breakCode)
	SHARED  breakPatchAddr[]
	SHARED  breakPatchCode[]
'
	uBreak = UBOUND(breakPatchAddr[])
	i = 0
	DO WHILE (breakPatchAddr[i])
		INC i
	LOOP WHILE (i <= uBreak)
	IF (i > uBreak) THEN
		uBreak = (uBreak + (uBreak >> 1)) OR 15
		REDIM breakPatchAddr[uBreak]
		REDIM breakPatchCode[uBreak]
	END IF
	breakPatchAddr[i] = breakAddr
	breakPatchCode[i] = breakCode
END FUNCTION
'
'
' ################################
' #####  GetRuntimeError ()  #####
' ################################
'
'	Get the Runtime Error information
'
'	In:				info$			strings passed by reference
'						msg$
'
'	Out:			info$			Info string
'						msg$			Message string
'
'	Return:		showMsg		TRUE		new error to consider
'											FALSE		breakpoint or user interrupt
'
'	Discussion:
'		Labels should be 55 chars max
'
'		SIGTRAP Vectors:
'			511 - unused (because used by 88Open trace utilities--sdb, etc)
'			510 - imbedded breakpoints
'			509 - system call (software interrupt) breakpoints
'			508 - unused
'			507 - Unexpected Higher/Lower Dim	(bounds check)
'			506 -	Need Null Node							(attach)
'			505 - Overflow										(arithmetic/conversion)
'			504 - General purpose							(uses ##ERROR)
'
'		- Two standard breakpoint traps (509,510) are required to handle
'				the two types of "continue" (one repeats the last instruction,
'				the other steps over it).
'		- The general purpose trap (504) is invoked with ##ERROR holding
'				the specific error number.
'				If ##ERROR = $$ErrorObjectSystem, errno has OS error#.
'		- Three other vectors (505,506,507) could be merged into the
'				general purpose trap, but are set alone because:
'					- We have the technology (I mean, the vectors are available.)
'					- These error traps are present in code whereever
'							bounds checking, ATTACHing, and type conversion is done.
'							Having unique vectors for these errors reduces code size,
'							code complexity, and number of labels.  It is good.
'
FUNCTION  GetRuntimeError (runtimeInfo$, runtimeMsg$)
	EXTERNAL  errno
	SHARED  sigNumber
	SHARED  EXCEPTION_RECORD  exceptionRecord
'
	runtimeInfo$ = " "
	runtimeMsg$ = " "
'
	oldError = $$FALSE
	showMsg  = $$TRUE
	sxip = exceptionRecord.exceptionAddress
'
	XstExceptionNumberToName (sigNumber, @runtimeMsg$)
'	PRINT "GetRuntimeError()"; sigNumber;; runtimeMsg$;;
	SELECT CASE sigNumber
		CASE 0
					oldError = $$TRUE
		CASE $$ExceptionSegmentViolation
					##ERROR = (($$ErrorObjectMemory << 8) OR $$ErrorNatureInvalidAccess)
		CASE $$ExceptionOutOfBounds
					##ERROR = (($$ErrorObjectArray << 8) OR $$ErrorNatureInvalidAccess)
		CASE $$ExceptionBreakpoint
					vector = ##TRAPVECTOR									' SIGTRAPs are vectors 504-511
					SELECT CASE TRUE
						CASE (vector = 509), (vector = 510)	' 509, 510 are breakpoint traps
									oldError = $$TRUE
									runtimeMsg$ = " Paused on breakpoint "
									showMsg = $$FALSE
						CASE (vector = 504)									' 504 - General purpose (XERROR)
						CASE (vector < 0)										' < 0 - Windows error
									runtimeMsg$ = " OS error #" + STRING$ (-vector)
						CASE ELSE
									runtimeMsg$ = " ExceptionBreakpoint:  Unknown vector " + STRING$ (vector)
					END SELECT
		CASE $$ExceptionBreakKey
					oldError = $$TRUE
					showMsg = $$FALSE
		CASE $$ExceptionAlignment
					##ERROR = (($$ErrorObjectMemory << 8) OR $$ErrorNatureInvalidAccess)
		CASE $$ExceptionDenormal
					##ERROR = (($$ErrorObjectData << 8) OR $$ErrorNatureInvalidFormat)
		CASE $$ExceptionInvalidOperation
					##ERROR = $$ErrorNatureInvalidOperation
		CASE $$ExceptionDivideByZero
					##ERROR = $$ErrorNatureDivideByZero
		CASE $$ExceptionOverflow
					##ERROR = $$ErrorNatureOverflow
		CASE $$ExceptionStackCheck
					##ERROR = (($$ErrorObjectMemory << 8) OR $$ErrorNatureOverflow)
		CASE $$ExceptionUnderflow
					##ERROR = $$ErrorNatureUnderflow
		CASE $$ExceptionPrivilege
					##ERROR = $$ErrorNaturePrivilege
		CASE $$ExceptionStackOverflow
					##ERROR = (($$ErrorObjectMemory << 8) OR $$ErrorNatureOverflow)
	END SELECT
'
'	PRINT ##ERROR;; "<"; ERROR$(##ERROR); ">"
	runtimeInfo$ = " Address " + HEX$(sxip, 8) + ":  " + ERROR$ (##ERROR)
	IF oldError THEN runtimeInfo$ = runtimeInfo$ + "  <== Previous error"
	RETURN (showMsg)
END FUNCTION
'
'
' ################################
' #####  WarningResponse ()  #####
' ################################
'
FUNCTION  WarningResponse (message$, okButton$, optionButton$)
	SHARED	messageFont
	SHARED	I_Information
	FUNCADDR	func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, ANY)
'
	IFZ message$ THEN RETURN
	newline = INSTR (message$, "\n")
'
	IF newline THEN
		left = INSTR (message$, "[")
		right = INSTR (message$, "]")
		IF ((left = 1) AND (right = (newline-1))) THEN
			title$ = MID$ (message$, 2, right-2)
			message$ = MID$ (message$, newline+1)
		END IF
	END IF
'
	func = &XuiMessage2B()
	IF optionButton$ THEN func = &XuiMessage3B()
'
' Message Window  ( generic message window )
'
	@func (@messageGrid, #CreateWindow, 0, 0, 0, 0, 0, 0)
	@func ( messageGrid, #SetTexture, $$TextureShadow, 0, 0, 0, 1, 0)
	@func ( messageGrid, #SetColorExtra, -1, -1, $$Black, $$Yellow, 1, 0)
	@func ( messageGrid, #SetColor, $$BrightBlue, $$Yellow, -1, -1, 1, 0)
'	@func ( messageGrid, #SetColor, $$BrightGreen, -1, -1, -1, 2, 0)
'	@func ( messageGrid, #SetColor, $$BrightGreen, -1, -1, -1, 3, 0)
'
	IFZ title$ THEN title$ = " message "
	@func ( messageGrid, #SetWindowTitle, 0, 0, 0, 0, 0, @title$)
	@func ( messageGrid, #SetTextString, 0, 0, 0, 0, 1, @message$)
	@func ( messageGrid, #SetTextString, 0, 0, 0, 0, 2, @okButton$)
'
	IF optionButton$ THEN
'		@func ( messageGrid, #SetColor, $$BrightGreen, -1, -1, -1, 4, 0)
		@func ( messageGrid, #SetTextString, 0, 0, 0, 0, 3, @optionButton$)
	END IF
'
	@func (messageGrid, #GetSmallestSize, 0, 0, @ww, @hh, 0, 0)
	ww = ww + 16 : hh = hh + 16
'
	width = (#displayWidth >> 1) - #windowBorderWidth - #windowBorderWidth
	height = (#displayHeight >> 1) - #windowTitleHeight
	IF (ww > width) THEN width = ww
	IF (hh > height) THEN height = hh
	xDisp = (#displayWidth >> 1) - (width >> 1) - #windowBorderWidth
	yDisp = (#displayHeight >> 1) - (height >> 1) - #windowBorderWidth
	@func ( messageGrid, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	@func ( messageGrid, #SetFontNumber, messageFont, 0, 0, 0, 1, 0)
	@func ( messageGrid, #ResizeWindow, xDisp, yDisp, width, height, 0, 0)
	@func ( messageGrid, #GetModalInfo, @v0, 0, 0, 0, @reply, 0)
	@func ( messageGrid, #Destroy, 0, 0, 0, 0, 0, 0)
'
	IF optionButton$ THEN
		SELECT CASE reply
			CASE 0		:	warningResponse = $$WarningProceed
									IF (v0{$$VirtualKey} = $$KeyEscape) THEN
										warningResponse = $$WarningCancel
									END IF
			CASE 2		:	warningResponse = $$WarningProceed
			CASE 3		:	warningResponse = $$WarningOption
			CASE 4		:	warningResponse = $$WarningCancel
			CASE ELSE	:	PRINT "WarningResponse() : unknown response ="; response
		END SELECT
	ELSE
		SELECT CASE reply
			CASE 0		:	warningResponse = $$WarningProceed
									IF (v0{$$VirtualKey} = $$KeyEscape) THEN
										warningResponse = $$WarningCancel
									END IF
			CASE 2		:	warningResponse = $$WarningProceed
			CASE 3		:	warningResponse = $$WarningCancel
			CASE ELSE	:	PRINT "WarningResponse() : unknown response ="; response
		END SELECT
	END IF
	RETURN (warningResponse)
END FUNCTION
'
'
' #########################
' #####  XitCrash ()  #####
' #########################
'
'  Save text/program file (if any)
'  Write error statistics to stat file
'  Warn user to quit immediately and restart PDE (no guarantees otherwise)
'
FUNCTION  XitCrash (sigNumber, sxip, fatal)
	SHARED  fileType,  xitGrid,  environmentEntered
	SHARED  funcNeedsTokenizing[]
	SHARED  processingCrash
	SHARED  saveCRLF
	SHARED  prog[]
	SHARED  teston
	STATIC  numCrashes
'
	IF (numCrashes > 2) THEN
		PRINT "Too many crashes to continue reliably."
		PRINT "  Exiting..."
		INLINE$ ("  Press RETURN: ")
		XitQuit (1)
	END IF
	INC numCrashes
	processingCrash = $$TRUE
	PRINT "\nEnvironment error!!!   at "; HEX$(sxip)
'
'	entryTeston = teston
'	teston = $$TRUE
'	TestHeaders ()
'	teston = entryTeston
'
	INLINE$("  Press RETURN: ")
'
	ofile$ = "xb.sav"
	SELECT CASE fileType
		CASE $$Text
					XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
					IFZ text$[] THEN EXIT SELECT
					PRINT "  Trying to save current text file as  "; ofile$
					ofile = OPEN (ofile$, $$WRNEW)
					IF (ofile < 0) THEN
						PRINT "    Failed to save:  OPEN failed"
						EXIT SELECT
					END IF
					IF saveCRLF THEN
						XstStringArrayToStringCRLF (@text$[], @text$)		' \r\n
					ELSE
						XstStringArrayToString (@text$[], @text$)				' \n
					END IF
					##ERROR = $$FALSE
					WRITE [ofile], text$
					SELECT CASE TRUE
						CASE ##ERROR	: PRINT "    Failed to save:  WRITE failed"
						CASE ELSE			: PRINT "    Saved successfully."
					END SELECT
					CLOSE (ofile)
'					SHELL ("sync &")
'					SetAlarm (0)								' reset and turn off alarm (UNUSED IN NT)
		CASE ELSE													' Program
					PRINT "  Trying to save current program as  "; ofile$
					ofile = OPEN (ofile$, $$WRNEW)
					IF (ofile < 0) THEN
						PRINT "    Failed to save:  OPEN failed"
						EXIT SELECT
					END IF
					redisplay = $$TRUE
					reportBogusRename = $$TRUE						' tokenize, resets BPs if necessary
					RestoreTextToProg (redisplay, reportBogusRename)
					ConvertProgToText ($$TextString, saveCRLF, $$AbortNotAllowed, @text$)
					##ERROR = $$FALSE
					WRITE [ofile], text$
					SELECT CASE TRUE
						CASE ##ERROR	: PRINT "    Failed to save:  WRITE failed"
						CASE ELSE			: PRINT "    Saved successfully."
					END SELECT
'					SHELL ("sync &")
					CLOSE (ofile)
'					SetAlarm (0)								' reset and turn off alarm (UNUSED IN NT)
	END SELECT
'
' Tell the bad news
'
	XstExceptionNumberToName (sigNumber, @signal$)
	SELECT CASE fatal
		CASE $$FatalSignalInEnv
			m0$ = "\nEnvironment SIGNAL #" + STRING$(sigNumber) + ":  "
			m0$ = m0$ + signal$ + "\n"
		CASE $$FatalSigQuitInAllo
			m0$ = "\nSIGQUIT interrupted memory allocation.\n"
		CASE ELSE
			m0$ = "\nUnknown fatal error (????).\n"
	END SELECT
	m1$ = "The environment is now in an undetermined state.\n"
	m2$ = "  It is recommended that you Quit execution immediately and restart.\n"
	m3$ = "  Should this problem persist, consult representative for assistance."
	message$ = m0$ + m1$ + m2$ + m3$
	PRINT message$
	processingCrash = $$FALSE
END FUNCTION
'
'
' ################################
' #####  AssemblyString$ ()  #####
' ################################
'
' funcNumber and lineNumber exist.  lineAddr[] is up to date.
'		(Environment access only--for displaying status)
'
'		Disassembly is so slow, put END PROGRAM at end of PROLOG instead
'			of entryFunction.
'			Also, save END PROGRAM info in endProgram$[]  (reset in CompileProgram())
'
'		DO: dump END PROGRAM literal strings (between litStringAddr and xpc)
'
FUNCTION  AssemblyString$ (funcNumber, lineNumber)
	EXTERNAL /xxx/  maxFuncNumber,  entryFunction,  litStringAddr,  xpc
	SHARED  prog[],  lineAddr[],  lineLast[],  endProgram$[]
	SHARED  softInterrupt
	SHARED  currentCursor
'
	entryCursor = currentCursor
	softInterrupt = $$FALSE
'
	ATTACH prog[funcNumber,] TO func[]
	ATTACH func[lineNumber,] TO tok[]
'	IF tok[] THEN
		startToken = tok[0]														' waste >: for trimming
		tok[0] = startToken{$$CLEAR_BP_EXE}
		XxxDeparser(@tok[], @asm$)
		asm$ = LTRIM$(asm$) + "\n"
		tok[0] = startToken
'	END IF
	ATTACH tok[] TO func[lineNumber,]
	ATTACH func[] TO prog[funcNumber,]
'
	SELECT CASE startToken{$$BP_EXE}
		CASE 3:		asm$ = ">: " + asm$									' ExeLine and BP
		CASE 2:		asm$ = ": " + asm$									' BP only
		CASE 1:		asm$ = "> " + asm$									' ExeLine only
	END SELECT
'
	nextAddr = lineAddr[funcNumber, lineNumber]
	lastAddr = lineAddr[funcNumber, lineNumber + 1]
	IF (lastAddr <= nextAddr) THEN									' comment or newline
		codeLines = 0
	ELSE
		codeLines = (lastAddr - nextAddr) + 1					' max lines + title line
	END IF
'
	DIM asmArray$[codeLines]
	line = 0
	asmChars = LEN(asm$)
	ATTACH asm$ TO asmArray$[line]
'
	DO WHILE (nextAddr < lastAddr)
		labels = XxxGetLabelGivenAddress (nextAddr, @labels$[])
		IF labels THEN
			FOR i = 0 TO labels-1
				asm$ = asm$ + labels$[i] + ":" + "\n"
			NEXT i
		END IF
		addr = nextAddr
		instruction$ = XxxDisassemble$ (@nextAddr, $$TRUE)
		asm$ = asm$ + "  " + HEX$(addr,8) + "   " + instruction$ + "\r\n"
'
		asmChars = asmChars + LEN(asm$)
		INC line
		ATTACH asm$ TO asmArray$[line]
'
		IFZ (line AND 0xFF) THEN												' Update every 64 lines
			SetCurrentStatus ($$StatusDecoding, line)
			IF softInterrupt THEN
				asm$ = "Assembly decoding aborted here..."
				asmChars = asmChars + LEN(asm$)
				INC line
				ATTACH asm$ TO asmArray$[line]
				GOTO concatStrings
			END IF
'			SetCursor ($$CursorWait)
		END IF
	LOOP
	codeLines = line
	REDIM asmArray$[codeLines]
'
'	END PROGRAM goes after last line in PROLOG
'	IF (funcNumber = entryFunction) THEN
	IFZ funcNumber THEN
		IF (lineNumber = lineLast[funcNumber]) THEN
			IFZ endProgram$[] THEN
				nextAddr = lineAddr[maxFuncNumber + 1, 0]
				lastAddr = litStringAddr
				IF (lastAddr > nextAddr) THEN
					endLines = lastAddr - nextAddr
					REDIM endProgram$[endLines]
					asm$ = "\nEND PROGRAM:\n\n"
					endLine = -1
					DO WHILE (nextAddr < lastAddr)
						labels = XxxGetLabelGivenAddress (nextAddr, @labels$[])
						IF labels THEN
							i = 0
							DO
								asm$ = asm$ + labels$[i] + ":" + "\n"
								INC i
							LOOP UNTIL (i >= labels)
						END IF
						addr = nextAddr
						asm$ = asm$ + "  " + HEX$(addr,8) + "  " + XxxDisassemble$ (@nextAddr, $$TRUE) + "\n"
						INC endLine:  INC line
						ATTACH asm$ TO endProgram$[endLine]

						IFZ (line AND 0xFF) THEN									' Update every 64 lines
							SetCurrentStatus ($$StatusDecoding, line)
							IF softInterrupt THEN
								asm$ = "Assembly decoding aborted here..."
								INC endLine:  INC line
								ATTACH asm$ TO endProgram$[endLine]
								REDIM asmArray$[line]
								FOR i = 0 TO endLine
									asmChars = asmChars + LEN(endProgram$[i])
									asmArray$[codeLines + i + 1] = endProgram$[i]
								NEXT i
								GOTO concatStrings
							END IF
'							SetCursor ($$CursorWait)
						END IF
					LOOP
					asm$ = "Literal String Definitions from " + HEXX$(litStringAddr,8) + " to " + HEXX$(xpc,8)
					INC endLine:  INC line
					ATTACH asm$ TO endProgram$[endLine]
					REDIM endProgram$[endLine]
				END IF
			END IF
			IF endProgram$[] THEN
				endLines = UBOUND(endProgram$[])
				line = codeLines + endLines + 1
				REDIM asmArray$[line]
				FOR i = 0 TO endLines
					asmChars = asmChars + LEN(endProgram$[i])
					asmArray$[codeLines + i + 1] = endProgram$[i]
				NEXT i
			END IF
		END IF
	END IF
'
concatStrings:
	asm$ = NULL$ (asmChars + 1)
	destAddr = &asm$
	offset = 0
	FOR i = 0 TO line
		IFZ asmArray$[i] THEN DO NEXT
		lastOffset = UBOUND(asmArray$[i])								' offset from 0
		srcAddr = &asmArray$[i]
		FOR j = 0 TO lastOffset
			UBYTEAT(destAddr, offset) = UBYTEAT(srcAddr, j)
			INC offset
		NEXT j
	NEXT i
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN
		SetCurrentStatus ($$StatusRunning, 0)
	END IF
'	SetCursor (entryCursor)
	RETURN (asm$)
END FUNCTION
'
'
' #########################
' #####  MainLoop ()  #####
' #########################
'
'	Xit processing of the XWindows events; exit if exitFlag set
'
'	In:				exitFlagAddr		Address of exit flag
'	Out:			none						arg unchanged
'	Return:		none
'
FUNCTION  MainLoop (exitFlagAddr)
	EXTERNAL /xxx/ errorCount
	SHARED  graphicsInitialized,  fileType
	SHARED  programAltered,  dispatchCount
	SHARED  currentCursor,  currentStatus
	SHARED  xitGrid
	STATIC	entered
'
	IFZ graphicsInitialized THEN
		Message (" MainLoop() \n\n GraphicsDesigner not initialized ")
		RETURN
	END IF
'
	error = $$TRUE
	addr = exitFlagAddr
	IF exitFlagAddr THEN
		SELECT CASE TRUE
			CASE ((addr > ##BSS0) AND (addr < ##BSSZ)) 		:	error = $$FALSE
			CASE ((addr > ##DATA0) AND (addr < ##DATAZ))	:	error = $$FALSE
			CASE ((addr > ##DYNO0) AND (addr < ##DYNOZ))	:	error = $$FALSE
		END SELECT
		IF error THEN THEN
			a$ = HEXX$(addr,8)
			PRINT a$
			PRINT MemoryMap$()
			Message (" MainLoop() \n\n exit flag address not in static memory \n\n " + a$ + " ")
			XstSleep (2500)
			RETURN
		END IF
	END IF
'
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN RETURN	' Exit if alarm is on...
'
	IFZ entered THEN
		entered = $$TRUE
		XstGetCommandLineArguments (@count, @arg$[])
		upper = count - 1
		IF count THEN
			FOR arg = 0 TO upper
				arg$ = arg$[arg]
				IF arg$ THEN
					command$ = ""
					SELECT CASE arg$
						CASE "-fl"	:	IF (arg < upper) THEN
														INC arg
														arg$ = arg$[arg]
														IF arg$ THEN command$ = ".fl " + arg$[arg]
													END IF
						CASE "-ft"	:	IF (arg < upper) THEN
														INC arg
														arg$ = arg$[arg]
														IF arg$ THEN command$ = ".ft " + arg$[arg]
													END IF
					END SELECT
					IF (command$) THEN
						XstLog (command$)
						length = LEN (command$)
'						XuiSendMessage (xitGrid, #GetTextCursor, @pos, @cursorLine, 0, 0, $$xitCommand, 0)
'						XuiSendMessage (xitGrid, #GrabTextArray, 0, 0, 0, 0, $$xitCommand, @text$[])
'						XstLog ("cursor x,y = " + STRING$(pos) + " " + STRING$(cursorLine) + " : " + STRING$(UBOUND(text$[])))
'						DIM text$[]
'						DIM text$[0]
'						text$[0] = command$
'						XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitCommand, @text$[])
'						XuiSendMessage (xitGrid, #SetTextCursor, length, 0, 0, 0, $$xitCommand, 0)
						AddCommandItem (@command$)
						ImmediateMode ($$KeyEnter)
					END IF
				END IF
			NEXT arg
		END IF
	END IF

'
'	PRINT "MainLoop() : beginning loop : status = "; status
'
	DO
'		IF (currentCursor != $$CursorReady) THEN SetCursor ($$CursorReady)
		IF (fileType != $$Program) THEN
			status = $$StatusEditing
		ELSE
			SELECT CASE TRUE
				CASE programAltered:												status = $$StatusEditing
				CASE (##USERRUNNING AND ##SIGNALACTIVE):		status = $$StatusPaused
				CASE ELSE:																	status = $$StatusCompiled
			END SELECT
		END IF
		IF (currentStatus != status) THEN SetCurrentStatus (status, 0)
		IF dispatchCount THEN Dispatch()				' dispatch delayed actions
		XgrProcessMessages (1)
		IF XLONGAT(exitFlagAddr) THEN EXIT DO
		IF dispatchCount THEN Dispatch()				' dispatch delayed actions
	LOOP
END FUNCTION
'
'
' ##################################
' #####  ClearMessageQueue ()  #####
' ##################################
'
'	Special processing of the Xit event queue
'
'	Discussion:
'		This routine is used by Xit routines to:
'			- Process #Redraw and #LostKeyboardFocus messages
'			- Look for a "abort" instruction (the ABORT button)
'
' Not used while program runs (the Alarm interrupt processes events).
' Routines with runtime conflicts have special code to avoid conflict.
'
FUNCTION  ClearMessageQueue ()
	SHARED  xitHotAbort
'
'	SHARED  teston
'	entryTeston = teston
'	teston = $$TRUE
'	TestHeaders ()
'	teston = entryTeston
'	CountHeaders ()
'
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN
'		PRINT "CMQ: don't do it: "; ##USERRUNNING, ##SIGNALACTIVE
		RETURN		' Let alarm handle it
	END IF
'
'	PRINT "ClearMessageQueue "; ##WHOMASK
	XgrMessagesPending(@count)
	IFZ count THEN RETURN
	DO
		XgrPeekMessage (@wingrid, @message, 0, 0, 0, 0, 0, 0)
		XgrMessageNumberToName (message, @message$)
'		PRINT "ClearMessageQueue() ", wingrid, message$, v0, v1, v2, v3,
		IF (wingrid = xitHotAbort) THEN
'			PRINT "... process HotAbort"
			XgrProcessMessages (1)
		ELSE
			SELECT CASE message
				CASE  #Redraw, #RedrawGrid, #RedrawText, #LostKeyboardFocus, #GotKeyboardFocus
'					PRINT "... process message"
					XgrProcessMessages (1)
				CASE ELSE
					XgrGetMessageType (message, @msgType)
					IF (msgType = $$Window) THEN
'						PRINT "... process message"
						XgrProcessMessages (1)
					ELSE
'						PRINT "... delete message"
						XgrDeleteMessages (1)
					END IF
			END SELECT
		END IF
		XgrMessagesPending (@count)
	LOOP WHILE count
'	PRINT "Exit ClearMessageQueue"
END FUNCTION
'
'
' ############################
' #####  AddDispatch ()  #####
' ############################
'
'	Add a function to the dispatch queue (execute AFTER a blowback)
'
FUNCTION  AddDispatch (funcAddress, arg)
	SHARED  dispatch[]
	SHARED  dispatchCount
'
	IFZ dispatch[] THEN DIM dispatch[7, 1]
'
	uPatch = UBOUND (dispatch[])
	IF (dispatchCount > uPatch) THEN
		uPatch = (dispatchCount + 7) OR 3
		REDIM dispatch[uPatch, 1]
	END IF
'
	dispatch[dispatchCount, 0] = funcAddress
	dispatch[dispatchCount, 1] = arg
	INC dispatchCount
END FUNCTION
'
'
' #########################
' #####  Dispatch ()  #####
' #########################
'
'	Dispatch queued functions after blowback
'
FUNCTION  Dispatch ()
	SHARED  dispatch[]
	SHARED  dispatchCount
	FUNCADDR XLONG func(XLONG)
'
	IF dispatchCount THEN
		FOR i = 0 TO (dispatchCount - 1)
			func = dispatch[i, 0]
			@func(dispatch[i, 1])
		NEXT i
		dispatchCount = 0
	END IF
END FUNCTION
'
'
' ###################################
' #####  EnableAbortSignals ()  #####
' ###################################
'
FUNCTION  EnableAbortSignals ()
	SHARED  sigs[]
'
	sigs[0] = &XitQuit()					' Quit releases shmid, resets echo
	sigs[1] = 0x00000000
	sigs[2] = 0x00000000
	sigs[3] = 0x00000000
END FUNCTION
'
'
' #################################
' #####  BreakClearArrays ()  #####
' #################################
'
FUNCTION  BreakClearArrays ()
	SHARED  breakAddr[63]
	SHARED  breakCode[63]
	SHARED  breakPatchAddr[7]
	SHARED  breakPatchCode[7]
END FUNCTION
'
'
' ##############################
' #####  BreakInternal ()  #####  Internal Breakpoints  #####
' ##############################
'
'	No breakpoints installed:
'		- in PROLOG
'		- at first line of Function
'			- this is always the FUNCTION line
'			- in all but the entryFunction, this line is never executed anyway
'				- (br _FuncName included for delineation)
'			- in the entryFunction, there are several lines of code terminating
'					the DimPreSharedArrays section.  These ARE executed, so a BP must
'					be avoided.
'
'	NT:  "opcode" refers to the FIRST BYTE of the opcode.  It simply needs to
'					be the length of the $$BREAK instruction (1 byte).
'				(2 bytes if #WINLESS)
'
FUNCTION  BreakInternal (command, func, line, addr)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  lineAddr[],  lineCode[],  lineLast[]
'
	SELECT CASE command
		CASE $$BreakRemoveAll:					GOSUB RemoveAllProgramLineBreakpoints
		CASE $$BreakInstallAll:					GOSUB InstallAllProgramLineBreakpoints
		CASE $$BreakInstallFunc:				GOSUB InstallAllFunctionLineBreakpoints
		CASE $$BreakInstallOne:					GOSUB InstallOneFunctionLineBreakpoint
		CASE $$BreakGetFuncLineOpcode:	GOSUB GetFuncAndLineAndOpcodeGivenAddress
		CASE ELSE:											PRINT "Bad command to BreakInternal()"
	END SELECT
	RETURN (0)
'
'
' Install breakpoint over 1st opcode of every source line in program
'
SUB InstallAllProgramLineBreakpoints
	func = 1																' No breakpoints in PROLOG
	DO UNTIL (func > maxFuncNumber)
		IFZ prog[func,] THEN INC func: DO DO
		lineAddr = lineAddr[func, 0]
		lineLast = lineLast[func]
		line = 0
		firstLine = $$TRUE
		DO UNTIL (line > lineLast)
			nextAddr = lineAddr[func, line + 1]
			IF (lineAddr < nextAddr) THEN				' Skip blank lines/comments
				IF firstLine THEN									' No breakpoints on FUNCTION line
					firstLine = $$FALSE
				ELSE
'					XLONGAT (lineAddr) = $$BREAK				' 88k
					IFZ #WINLESS THEN
						UBYTEAT (lineAddr) = $$BREAK1			' NT 1 byte
					ELSE
						USHORTAT (lineAddr) = $$BREAK2		' NT 2 byte
					END IF
				END IF
			END IF
			lineAddr = nextAddr
			INC line
		LOOP
		INC func
	LOOP
END SUB
'
'
'	Install breakpoint over 1st opcode of lineNumber line in function func
'		If FUNCTION line, install it on next valid line
'
SUB InstallOneFunctionLineBreakpoint
	IFZ func THEN EXIT SUB							' No breakpoints in PROLOG
	IF (line > lineLast[func]) THEN RETURN (0)
	bpLineAddr = lineAddr[func, line]
'
'	Find line following FUNCTION line ("second" line)
'
	lineAddr = lineAddr[func, 0]
	lineLast = lineLast[func]
	line = 0
	firstLine = $$TRUE
	DO UNTIL (line > lineLast)
		nextAddr = lineAddr[func, line + 1]
		IF (lineAddr < nextAddr) THEN			' Skip blank lines/comments
			IF firstLine THEN
				firstLine = $$FALSE
			ELSE
				EXIT DO
			END IF
		END IF
		lineAddr = nextAddr
		INC line
	LOOP
'
	IF (bpLineAddr < lineAddr) THEN bpLineAddr = lineAddr
'
	IFZ #WINLESS THEN
		UBYTEAT (bpLineAddr) = $$BREAK1			' NT 1 byte
	ELSE
		USHORTAT (bpLineAddr) = $$BREAK2		' NT 2 byte
	END IF
END SUB
'
'
'	Install breakpoint over 1st opcode of every source line in one function
'
SUB InstallAllFunctionLineBreakpoints
	IFZ func THEN EXIT SUB							' No breakpoints in PROLOG
	lineAddr = lineAddr[func, 0]
	lineLast = lineLast[func]
	line = 0
	firstLine = $$TRUE
	DO UNTIL (line > lineLast)
		nextAddr = lineAddr[func, line + 1]
		IF (lineAddr < nextAddr) THEN			' Skip blank lines/comments
			IF firstLine THEN								' No breakpoints on FUNCTION line
				firstLine = $$FALSE
			ELSE
'				XLONGAT (lineAddr) = $$BREAK				' 88k
				IFZ #WINLESS THEN
					UBYTEAT (lineAddr) = $$BREAK1			' NT 1 byte
				ELSE
					USHORTAT (lineAddr) = $$BREAK2		' NT 2 byte
				END IF
			END IF
		END IF
		lineAddr = nextAddr
		INC line
	LOOP
END SUB
'
'
'	Remove breakpoints from 1st opcode on every source line in program
'
SUB RemoveAllProgramLineBreakpoints
	IFZ prog[] THEN EXIT SUB					' no prog[] in low level debugger
	func = 1													' No breakpoints in PROLOG
	DO UNTIL (func > maxFuncNumber)
		IFZ prog[func,] THEN INC func: DO DO
		lineAddr = lineAddr[func, 0]
		lineLast = lineLast[func]
		line = 0
		DO UNTIL (line > lineLast)
			nextAddr = lineAddr[func, line + 1]
			IF (lineAddr < nextAddr) THEN			' Skip blank lines/comments
				IFZ #WINLESS THEN
					UBYTEAT (lineAddr) = lineCode[func, line]			' NT 1 byte
'					IF (UBYTEAT (lineAddr) = $$BREAK1) THEN PRINT "BreakInternal: Remove "; HEX$(lineAddr,8)
				ELSE
					USHORTAT (lineAddr) = lineCode[func, line]		' NT 2 byte
'					IF (USHORTAT (lineAddr) = $$BREAK2) THEN PRINT "BreakInternal: Remove "; HEX$(lineAddr,8)
				END IF
			END IF
			lineAddr = nextAddr
			INC line
		LOOP
		INC func
	LOOP
END SUB
'
'
'	Get funcNumber and lineNumber given an address
'		NT:  "opcode" is first byte of opcode
'
SUB GetFuncAndLineAndOpcodeGivenAddress
	func = 1															' No breakpoints in PROLOG
	DO UNTIL (func > maxFuncNumber)
		IFZ prog[func,] THEN INC func: DO DO
		lineLast = lineLast[func]
		line = 0
		DO UNTIL (line > lineLast)
			lineAddr = lineAddr[func, line]
			lineCode = lineCode[func, line]
			IF (lineAddr = addr) THEN RETURN (lineCode)
			INC line
		LOOP
		INC func
	LOOP
	RETURN (-1)														' NT:  error is -1, not 0
END SUB
END FUNCTION
'
'
' ################################
' #####  BreakProgrammer ()  #####  Programmer Breakpoints  #####
' ################################
'
FUNCTION  BreakProgrammer (command, arg1, func)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  breakAddr[],  breakCode[],  prog[]
	SHARED  lineAddr[],  lineCode[],  lineLast[]
	SHARED  breakpointsAltered
'
	ubreak = UBOUND(breakAddr[])
	SELECT CASE command
		CASE $$BreakClearAll:			GOSUB ClearAllProgrammerBreakpoints
		CASE $$BreakClearFunc:		GOSUB ClearAllFunctionProgrammerBreakpoints
		CASE $$BreakClearOne:			GOSUB ClearOneProgrammerBreakpoint
		CASE $$BreakCheckOne:			GOSUB CheckOneProgrammerBreakpoint
		CASE $$BreakSetOne:				GOSUB SetOneProgrammerBreakpoint
		CASE $$BreakGetOpcode:		GOSUB GetOneProgrammerBreakpointOpcode
		CASE $$BreakInstallAll:		GOSUB InstallAllProgrammerBreakpoints
		CASE $$BreakRemoveAll:		GOSUB RemoveAllProgrammerBreakpoints
		CASE $$BreakRemoveOne:		GOSUB RemoveOneProgrammerBreakpoint
		CASE ELSE:								PRINT "Bad command to BreakProgrammer()"
	END SELECT
	RETURN (0)
'
'
'  *****  Clear All Programmer Breakpoints  *****
'
SUB ClearAllProgrammerBreakpoints
	i = 0
	DO UNTIL (i > ubreak)
		ba = breakAddr[i]
		IF (ba >= ##UCODE0) THEN							' Restore user code
			IF (ba < ##UCODEZ) THEN
				IFZ #WINLESS THEN
					UBYTEAT (ba) = breakCode[i]			' NT 1 byte
				ELSE
					USHORTAT (ba) = breakCode[i]		' NT 2 byte
				END IF
			END IF
		END IF
		breakAddr[i] = 0
		breakCode[i] = 0
		INC i
	LOOP
END SUB
'
'
'  *****  Clear All Function Programmer Breakpoints  *****
'
SUB ClearAllFunctionProgrammerBreakpoints
	lineLast = lineLast[func]
	line = 0
	DO UNTIL (line > lineLast)
		lineAddr = lineAddr[func, line]
		i = 0
		DO UNTIL (i > ubreak)
			ba = breakAddr[i]
			IF (ba = lineAddr) THEN
				IF (ba >= ##UCODE0) THEN							' Restore user code
					IF (ba < ##UCODEZ) THEN
						IFZ #WINLESS THEN
							UBYTEAT (ba) = breakCode[i]			' NT 1 byte
						ELSE
							USHORTAT (ba) = breakCode[i]		' NT 2 byte
						END IF
					END IF
				END IF
				breakAddr[i] = 0
				breakCode[i] = 0
			END IF
			INC i
		LOOP
		INC line
	LOOP
END SUB
'
'
'  *****  Clear One Programmer Breakpoint at address "arg1"  *****
'
SUB ClearOneProgrammerBreakpoint
	i =  0
	DO UNTIL (i > ubreak)
		ba = breakAddr[i]
		IF (ba = arg1) THEN
			IF (ba >= ##UCODE0) THEN							' Restore user code
				IF (ba < ##UCODEZ) THEN
					IFZ #WINLESS THEN
						UBYTEAT (ba) = breakCode[i]			' NT 1 byte
					ELSE
						USHORTAT (ba) = breakCode[i]		' NT 2 byte
					END IF
				END IF
			END IF
			breakAddr[i] = 0
			breakCode[i] = 0
			EXIT SUB
		END IF
		INC i
	LOOP
END SUB
'
'
'  *****  Check for Programm Breakpoint at address "arg1"
'
SUB CheckOneProgrammerBreakpoint
	i =  0
	DO UNTIL (i > ubreak)
		ba = breakAddr[i]
		IF (ba = arg1) THEN RETURN ($$TRUE)
		INC i
	LOOP
	RETURN ($$FALSE)
END SUB
'
'
' *****  Set Programmer Breakpoint at address "arg1"
'
SUB SetOneProgrammerBreakpoint
	IFZ arg1 THEN
		Message (" can't set breakpoint \n\n address = 0x00000000 ")
		EXIT SUB
	END IF
	IF ((arg1 < ##UCODE0) OR (arg1 >= ##UCODEZ)) THEN
		Message (" can't set breakpoint \n\n bad address ")
		EXIT SUB
	END IF
'
	IFZ #WINLESS THEN
		tempCode = UBYTEAT (arg1)			' NT 1 byte
		break = $$BREAK1
	ELSE
		tempCode = USHORTAT (arg1)		' NT 2 byte
		break = $$BREAK2
	END IF
	IF (tempCode = break) THEN
		Message (" SetOneProgBreakpoint \n\n found breakpoint already there ")
		EXIT SUB
	END IF
'
	i = 0
	firstOpenSlot = -1
	DO UNTIL (i > ubreak)
		ba = breakAddr[i]
		IF (ba = arg1) THEN EXIT SUB				' breakpoint already set here
		IF (firstOpenSlot < 0) THEN
			IFZ ba THEN firstOpenSlot = i
		END IF
		INC i
	LOOP
	IF (firstOpenSlot < 0) THEN
		Message (" SetOneProgBreakpoint \n\n no room in breakpoint array ")
		EXIT SUB
	END IF
'	PRINT "BreakProgrammer: SetOne success "; HEX$(arg1,8), HEX$(tempCode,8)
	breakAddr[firstOpenSlot] = arg1				' Store breakpoint address in array
	breakCode[firstOpenSlot] = tempCode		' store op code at breakpoint address
	RETURN ($$TRUE)
END SUB
'
'
'  *****  Get Opcode Under Programmer Breakpoint at address "arg1"
'
SUB GetOneProgrammerBreakpointOpcode
	i =  0
	DO UNTIL (i > ubreak)
		ba = breakAddr[i]
		IF (ba = arg1) THEN RETURN (breakCode[i])
		INC i
	LOOP
	RETURN ($$FALSE)
END SUB
'
'
'  *****  Install All Programmer Breakpoints  *****
'
SUB InstallAllProgrammerBreakpoints
	SELECT CASE TRUE
		CASE breakpointsAltered
			GOSUB ClearAllProgrammerBreakpoints
			IFZ prog[] THEN EXIT SUB
			func = 1														' Prolog BP not allowed
			i = 0
			excess = $$FALSE
			DO UNTIL (func > maxFuncNumber) OR excess
				IFZ prog[func,] THEN INC func: DO DO
				ATTACH prog[func,] TO func[]
				uLine = UBOUND(func[])
				line = 0
				DO UNTIL (line > uLine) OR excess
					IF func[line, 0]{$$BP} THEN
						ba = lineAddr[func, line]
						bc = lineCode[func, line]
						IF ((ba >= ##UCODE0) AND (ba < ##UCODEZ)) THEN
'							PRINT "BreakPoint Install: "; HEX$(ba,8)
							breakAddr[i] = ba						' Store breakpoint address in array
							breakCode[i] = bc						' Store op code in array
							IFZ #WINLESS THEN
								temp = UBYTEAT (ba)				' NT 1 byte
								break = $$BREAK1
							ELSE
								temp = USHORTAT (ba)			' NT 2 byte
								break = $$BREAK2
							END IF
							IF (temp != break) THEN
								IFZ #WINLESS THEN
									UBYTEAT (ba) = $$BREAK1			' NT 1 byte
								ELSE
									USHORTAT (ba) = $$BREAK2		' NT 2 byte
								END IF
							END IF
						END IF
						INC i
						IF (i > ubreak) THEN excess = $$TRUE
					END IF
					INC line
				LOOP
				ATTACH func[] TO prog[func,]
				INC func
			LOOP
			IF excess THEN
				nb = ubreak + 1
				Message (" only loaded first " + STRING$(nb) + " breakpoints ")
			END IF
			breakpointsAltered = $$FALSE

		CASE ELSE
			i = 0
			DO UNTIL (i > ubreak)
				ba = breakAddr[i]
				IF ba THEN
'					PRINT "BreakPoint Install: "; HEX$(ba,8)
					IF ((ba >= ##UCODE0) AND (ba < ##UCODEZ)) THEN
						IFZ #WINLESS THEN
							temp = UBYTEAT (ba)					' NT 1 byte
							break = $$BREAK1
						ELSE
							temp = USHORTAT (ba)				' NT 2 byte
							break = $$BREAK2
						END IF
						IF (temp != break) THEN
							IFZ #WINLESS THEN
								UBYTEAT (ba) = $$BREAK1			' NT 1 byte
							ELSE
								USHORTAT (ba) = $$BREAK2		' NT 2 byte
							END IF
						END IF
					END IF
				END IF
				INC i
			LOOP
	END SELECT
END SUB
'
'
'  *****  Remove All Programmer Breakpoints  *****
'
SUB RemoveAllProgrammerBreakpoints
	i = 0
	DO UNTIL (i > ubreak)
		ba = breakAddr[i]
		IF ba THEN
			IF (ba >= ##UCODE0) THEN
				IF (ba < ##UCODEZ) THEN
					IFZ #WINLESS THEN
						UBYTEAT (ba) = breakCode[i]		' NT 1 byte
					ELSE
						USHORTAT (ba) = breakCode[i]	' NT 2 byte
					END IF
				END IF
			END IF
		END IF
		INC i
	LOOP
END SUB
'
'
'  *****  Remove One Programmer Breakpoint  *****
'
SUB RemoveOneProgrammerBreakpoint
	i = 0
	DO UNTIL (i > ubreak)
		ba = breakAddr[i]
		IF ba THEN
			IF (ba = arg1) THEN
				IFZ #WINLESS THEN
					UBYTEAT (ba) = breakCode[i]		' NT 1 byte
				ELSE
					USHORTAT (ba) = breakCode[i]	' NT 2 byte
				END IF
				EXIT SUB
			END IF
		END IF
		INC i
	LOOP
END SUB
END FUNCTION
'
'
' ##################################################
' #####  GetFuncAndLineNumberAtThisAddress ()  #####
' ##################################################
'
'	Scan line arrays for current address (UpdateFrames used with environment)
'
FUNCTION  GetFuncAndLineNumberAtThisAddress (addr)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  lineAddr[],  lineLast[]
	SHARED  exeFunction,  exeLine
'
	exeFunction = 0
	exeLine = 0
	IFZ lineAddr[] THEN RETURN
	IFZ lineLast[] THEN RETURN
'
	func = 0
	DO UNTIL (func > maxFuncNumber)
		IFZ prog[func,] THEN INC func: DO DO
		lineAddr = lineAddr[func, 0]
		lineLast = lineLast[func]
		line = 0
		DO UNTIL (line > lineLast)
			nextAddr = lineAddr[func, line + 1]
			IF ((lineAddr <= addr) AND (addr < nextAddr)) THEN
				exeFunction = func
				exeLine = line
				RETURN
			END IF
			lineAddr = nextAddr
			INC line
		LOOP
		INC func
	LOOP
END FUNCTION
'
'
'  ###########################
'  #####  XitExecute ()  #####
'  ###########################
'
FUNCTION  XitExecute ()
	SHARED	exitMainLoop
	SHARED  environmentActive
	SHARED	environmentEntered
'
	IFZ environmentEntered THEN
		failed = CreateWindows ()
		IF failed THEN
			PRINT "Cannot start environment:  Windows is not running"
			environmentActive = $$FALSE
			RETURN
		END IF
	END IF
'
	InitWindows()
	exitMainLoop = $$FALSE
	environmentActive = $$TRUE
	MainLoop (&exitMainLoop)
END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()
	EXTERNAL  /xxx/  checkBounds
	SHARED  popupGrids[]
	SHARED  environmentEntered,  graphicsInitialized
	SHARED  waitCursor
	SHARED  xitGrid,  xitWindow,  xitCommand,  xitTextLower,  xitHotAbort
	SHARED  tabWidth,  textCursor
	SHARED	mainTitle$
'
'	Xit environment popup boxes:  grid numbers
'
	SHARED	welcomeGrid
	SHARED  newBox,  fileBox,  modeBox,  renameBox
	SHARED  findBox,  readBox,  writeBox,  abandonBox
	SHARED  funcBox,  viewNewBox,  deleteFuncBox,  viewRenameBox
	SHARED  viewCloneBox,  viewLoadBox,  viewSaveBox,  viewMergeBox,  viewImportBox
	SHARED  optionMiscBox,  optTabBox,  optFontBox
	SHARED  memoryBox,  assemblyBox,  registerBox
	SHARED  errorBox,  runtimeErrorBox
	SHARED  variableBox,  arrayBox,  stringBox,  compositeBox
	SHARED  framesBox
	SHARED  warning2Box,  warning3Box
	SHARED  buttonFont
	SHARED	labelFont
'
  $Command              = 34  ' kid 34 grid type = XuiDropBox
  $HotAbort             = 13  ' kid 13 grid type = XuiPushButton
  $TextLower            = 35  ' kid 35 grid type = XuiTextArea
'
' ******************************
' *****  CODE STARTS HERE  *****
' ******************************
'
	IF environmentEntered THEN RETURN ($$FALSE)			' environment exists
	IFZ graphicsInitialized THEN RETURN ($$TRUE)		' graphics unavailable
'
'	*****  Create EnvironmentWindow  *****  Size for display width/height
'
' ***********************************************
' *****  old size code for old main window  *****
' ***********************************************
'
'	SELECT CASE TRUE
'		CASE (#displayWidth >= 1000)	: width = 600
'		CASE (#displayWidth >=  768)	: width = 600
'		CASE (#displayWidth >=  640)	: width = 600
'		CASE ELSE											: width = 600
'	END SELECT
'
'	halfHeight = (#displayHeight >> 1) - #windowBorderWidth - #windowBorderWidth - #windowTitleHeight
'	halfWidth = (#displayWidth >> 1) - #windowBorderWidth - #windowBorderWidth
'
'	SELECT CASE TRUE
'		CASE (#displayHeight >= 1000)	: height = halfHeight
'		CASE (#displayHeight >=  768)	: height = halfHeight
'		CASE (#displayHeight >=  600)	: height = 400
'		CASE ELSE											: height = 360
'	END SELECT
'
'	xDisp = #displayWidth - width - #windowBorderWidth
'	yDisp = #displayHeight - height - #windowBorderWidth
'	IF (xDisp < #windowBorderWidth) THEN xDisp = #windowBorderWidth
'	IF (yDisp < (#windowBorderWidth + #windowTitleHeight)) THEN yDisp = #windowBorderWidth + #windowTitleHeight
'
'
' ***********************************************
' *****  new size code for new main window  *****
' ***********************************************
'
' compute initial size and position of window
'   minimal width for 80 character line
'   half display height
'
	XgrGetDisplaySize ("", @#displayWidth, @#displayHeight, @#windowBorderWidth, @#windowTitleHeight)
	line$ = "01234567890123456789012345678901234567890123456789012345678901234567890123456789"
	XgrGetTextImageSize (0, @line$, @dx, @dy, @width, @height, @gap, @space)
	maxwidth = #displayWidth - #windowBorderWidth - #windowBorderWidth
	textwidth = width + 32
'
	h = (#displayHeight >> 1) - #windowBorderWidth - #windowBorderWidth - #windowTitleHeight
	y = (#displayHeight >> 1) + #windowTitleHeight + #windowBorderWidth
	w = (#displayWidth >> 1) - #windowBorderWidth - #windowBorderWidth
	IF (w < textwidth) THEN w = textwidth
	IF (w > maxwidth) THEN w = maxwidth
	x = #displayWidth - w - #windowBorderWidth

'
	IFZ mainTitle$ THEN mainTitle$ = " main window "
	Environment    (@xitGrid, #CreateWindow, x, y, w, h, 0, 0)
	XuiSendMessage ( xitGrid, #SetCallback, xitGrid, &EnvironmentCode(), -1, -1, -1, xitGrid)
	XuiSendMessage ( xitGrid, #SetWindowTitle, 0, 0, 0, 0, 0, @mainTitle$)
	XuiSendMessage ( xitGrid, #GetWindow, @xitWindow, 0, 0, 0, 0, 0)
	XuiSendMessage ( xitGrid, #GetGridNumber, @xitCommand, 0, 0, 0, $Command, 0)
	XuiSendMessage ( xitGrid, #GetGridNumber, @xitTextLower, 0, 0, 0, $TextLower, 0)
	XuiSendMessage ( xitGrid, #GetGridNumber, @xitHotAbort, 0, 0, 0, $HotAbort, 0)
'	XuiSendMessage ( xitGrid, #SetFontNumber, labelFont, 0, 0, 0, $$xitFileLabel, 0)
'	XuiSendMessage ( xitGrid, #SetFontNumber, labelFont, 0, 0, 0, $$xitFunction, 0)
'	XuiSendMessage ( xitGrid, #SetFontNumber, labelFont, 0, 0, 0, $$xitStatusLabel, 0)
'	XuiSendMessage ( xitGrid, #SetFontNumber, labelFont, 0, 0, 0, $$xitErrorLabel, 0)
	XuiSendMessage ( xitGrid, #GetFontNumber, @font, 0, 0, 0, 0, 0)
	XgrGetFontMetrics (font, @maxCharWidth, 0, 0, 0, 0, 0)
	tabWidth = maxCharWidth << 1
	XgrSetCursorOverride (waitCursor, @entryCursor)
	XuiSendMessage ( xitGrid, #SetGridProperties, -1, 0, 0, 0, 0, 0)
'
'
' *****************************************
' *****  Xit Environment Popup Boxes  *****
' *****************************************
'
	windowType = $$WindowTypeTopMost OR $$WindowTypeSystemMenu OR $$WindowTypeTitleBar OR $$WindowTypeMaximizeBox OR $$WindowTypeMinimizeBox
	windowType = windowType OR xitWindow
	editFilename$ = $$PathSlash$ + "xb" + $$PathSlash$
'	dir$ = editFilename$
' File Load/Save defaults to the current directory.
	XstGetCurrentDirectory(@dir$)
'
	x0 = #windowBorderWidth
	y0 = #windowBorderWidth + #windowTitleHeight
'
'
' **********************************************************
' *****  create and initialize all XBasic IDE windows  *****
' **********************************************************
'
'
'
' *****  HelpAbout  *****  XuiMessage1B  *****
'
	HelpAbout (0)
'
'
' *****  FileNew  *****  XuiMessage4B  *****
'
	DIM r1$[5]
	r1$[1] = " begin new <text file> or <program> or <gui program> "
	r1$[2] = " text file "
	r1$[3] = " program "
	r1$[4] = " gui program "
	r1$[5] = " cancel "
	XuiMessage4B   (@newBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( newBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" new file ")
	XuiSendMessage ( newBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( newBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:FileNew")
'	XuiSendMessage ( newBox, #SetFontNumber, labelFont, 0, 0, 0, -1, 0)
	XuiSendMessage ( newBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (newBox, 0)
'
'
' *****  FileTextLoad  *****  XuiFile  *****
'
	XuiFile        (@fileBox, #CreateWindow, x0, y0, 400, 480, windowType, 0)
	XuiSendMessage ( fileBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" select file ")
	XuiSendMessage ( fileBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:SelectFile")
	XuiSendMessage ( fileBox, #SetTextString, 0, 0, 0, 0, 0, dir$)
	XuiSendMessage ( fileBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	XuiSendMessage ( fileBox, #Update, 0, 0, 0, 0, 0, 0)
	AlignWindow (fileBox, 0)
'
'
' *****  FileMode  *****  XuiMessage3B  *****
'
	DIM r1$[4]
	r1$[1] = " convert to program or text mode "
	r1$[2] = " program "
	r1$[3] = " text "
	r1$[4] = " cancel "
	XuiMessage3B   (@modeBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( modeBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" file mode ")
	XuiSendMessage ( modeBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( modeBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:FileMode")
	XuiSendMessage ( modeBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (modeBox, 0)
'
'
' *****  FileRename  *****  XuiDialog2B  *****
'
	DIM r1$[4]
	r1$[1] = " rename filename "
	r1$[3] = " rename "
	r1$[4] = " cancel "
	XuiDialog2B    (@renameBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( renameBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" rename file ")
	XuiSendMessage ( renameBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( renameBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:FileRename")
	XuiSendMessage ( renameBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (renameBox, 0)
'
'
' *****  EditFind  *****  XitFind  *****  Non-Modal
'
	XitFind        (@findBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( findBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" find / replace ")
	XuiSendMessage ( findBox, #SetCallback, findBox, &EditFind(), -1, -1, -1, findBox)
	XuiSendMessage ( findBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:EditFind")
	XuiSendMessage ( findBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (findBox, 0)
'
'
' *****  EditRead  *****  XuiFile  *****
'
	XuiFile        (@readBox, #CreateWindow, x0, y0, 400, 480, windowType, 0)
	XuiSendMessage ( readBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" read file ")
	XuiSendMessage ( readBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:EditRead")
	XuiSendMessage ( readBox, #SetTextString, 0, 0, 0, 0, 0, dir$)
	XuiSendMessage ( readBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	XuiSendMessage ( readBox, #Update, 0, 0, 0, 0, 0, 0)
	AlignWindow (readBox, 0)
'
'
' *****  EditWrite  *****  XuiFile  *****
'
	XuiFile        (@writeBox, #CreateWindow, x0, y0, 400, 480, windowType, 0)
	XuiSendMessage ( writeBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" write file ")
	XuiSendMessage ( writeBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:EditWrite")
	XuiSendMessage ( writeBox, #SetTextString, 0, 0, 0, 0, 0, dir$)
	XuiSendMessage ( writeBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	XuiSendMessage ( writeBox, #Update, 0, 0, 0, 0, 0, 0)
	AlignWindow (writeBox, 0)
'
'
' *****  EditAbandon  *****  XuiMessage2B  *****
'
	DIM r1$[3]
	r1$[1] = " text has not been altered "
	r1$[2] = " ok "
	r1$[3] = " cancel "
	XuiMessage2B   (@abandonBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( abandonBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" abandon edits ")
	XuiSendMessage ( abandonBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( abandonBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:EditAbandon")
	XuiSendMessage ( abandonBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (abandonBox, 0)
'
'
' *****  ViewFunction  *****  XuiListDialog2B  *****  Non-Modal
'
	DIM r1$[4]
	r1$[1] = " function name "
	r1$[4] = " view "
	XuiListDialog2B (@funcBox, #CreateWindow, x0, y0, 100, 200, windowType, 0)
	XuiSendMessage  ( funcBox, #SetCallback, funcBox, &ViewFunc(), -1, -1, -1, funcBox)
	XuiSendMessage  ( funcBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" view function ")
	XuiSendMessage  ( funcBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ViewFunction")
	XuiSendMessage  ( funcBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage  ( funcBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (funcBox, 0)
'
'
' *****  ViewNewFunc  *****  XuiDialog2B  *****
'
	DIM r1$[3]
	r1$[1] = " new function name "
	r1$[3] = " view "
	XuiDialog2B    (@viewNewBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( viewNewBox, #SetCallback, viewNewBox, &ViewNewFunc(), -1, -1, -1, viewNewBox)
	XuiSendMessage ( viewNewBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" new function ")
	XuiSendMessage ( viewNewBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( viewNewBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ViewNew")
	XuiSendMessage ( viewNewBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (viewNewBox, 0)
'
'
' *****  ViewDeleteFunc  *****  XuiListDialog2B  *****  Non-Modal
'
	DIM r1$[4]
	r1$[1] = " function name "
	r1$[4] = " delete "
	XuiListDialog2B (@deleteFuncBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( deleteFuncBox, #SetCallback, deleteFuncBox, &ViewDeleteFunc(), -1, -1, -1, deleteFuncBox)
	XuiSendMessage ( deleteFuncBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" delete function ")
	XuiSendMessage ( deleteFuncBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ViewDelete")
	XuiSendMessage ( deleteFuncBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( deleteFuncBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (deleteFuncBox, 0)
'
'
' *****  ViewRenameFunc  *****  XuiDialog2B  *****
'
	DIM r1$[3]
	r1$[1] = " new function name "
	r1$[3] = " rename "
	XuiDialog2B    (@viewRenameBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( viewRenameBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" rename function ")
	XuiSendMessage ( viewRenameBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( viewRenameBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ViewRename")
	XuiSendMessage ( viewRenameBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (viewRenameBox, 0)
'
'
' *****  ViewCloneFunc  *****  XuiDialog2B  *****
'
	DIM r1$[3]
	r1$[1] = " function name for clone "
	r1$[3] = " clone "
	XuiDialog2B    (@viewCloneBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( viewCloneBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" clone function ")
	XuiSendMessage ( viewCloneBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( viewCloneBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ViewClone")
	XuiSendMessage ( viewCloneBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (viewCloneBox, 0)
'
'
' *****  ViewLoadFunc  *****  Xit2LineDialog  *****
'
	DIM r1$[5]
	r1$[1] = " function name to load "
	r1$[3] = " file name to load "
	r1$[5] = " load "
	Xit2LineDialog (@viewLoadBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( viewLoadBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" load function ")
	XuiSendMessage ( viewLoadBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( viewLoadBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ViewLoad")
	XuiSendMessage ( viewLoadBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (viewLoadBox, 0)
'
'
' *****  ViewSaveFunc  *****  Xit2LineDialog  *****
'
	DIM r1$[5]
	r1$[1] = " function name to save "
	r1$[3] = " file name to save "
	r1$[5] = " save "
	Xit2LineDialog (@viewSaveBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( viewSaveBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" save function ")
	XuiSendMessage ( viewSaveBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( viewSaveBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ViewSave")
	XuiSendMessage ( viewSaveBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (viewSaveBox, 0)
'
'
' *****  ViewMergePROLOG  *****  XuiDialog2B  *****
'
	DIM r1$[3]
	r1$[1] = " file name to merge with prolog "
	r1$[3] = " merge "
	XuiDialog2B    (@viewMergeBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( viewMergeBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" merge prolog ")
	XuiSendMessage ( viewMergeBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( viewMergeBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ViewMerge")
	XuiSendMessage ( viewMergeBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (viewMergeBox, 0)
'
'
' *****  ViewImportFunctionFromProgram  *****  Xit2LineDialog  *****
'
	DIM r1$[5]
	r1$[1] = " function name to import "
	r1$[3] = " file name to load "
	r1$[5] = " import "
	Xit2LineDialog (@viewImportBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( viewImportBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" import function ")
	XuiSendMessage ( viewImportBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( viewImportBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ViewImport")
	XuiSendMessage ( viewImportBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (viewImportBox, 0)
'
'
' *****  OptionMisc  *****  XitOptionMisc  *****
'
	XitOptionMisc  (@optionMiscBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( optionMiscBox, #SetCallback, optionMiscBox, &XitOptionMiscCode(), -1, -1, -1, optionMiscBox)
	XuiSendMessage ( optionMiscBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" miscellaneous options ")
	XuiSendMessage ( optionMiscBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:OptionMisc")
	XuiSendMessage ( optionMiscBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (optionMiscBox, 0)
'
'
' *****  OptionTabWidth  *****  XuiDialog2B  *****
'
	DIM r1$[4]
	r1$[1] = " tab width "
	r1$[3] = " set "
	r1$[4] = " cancel "
	XuiDialog2B    (@optTabBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( optTabBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" tab width ")
	XuiSendMessage ( optTabBox, #SetTextStrings, 0, 0, 0, 0, 0, @r1$[])
	XuiSendMessage ( optTabBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:OptionTabs")
	XuiSendMessage ( optTabBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (optTabBox, 0)
'
'
' *****  OptionTextCursor  *****  XuiColor  *****
'
	XitTextCursor  (@textCursor, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( textCursor, #SetCallback, textCursor, &OptionTextCursor(), -1, -1, -1, textCursor)
	XuiSendMessage ( textCursor, #SetWindowTitle, 0, 0, 0, 0, 0, @" text cursor color ")
	XuiSendMessage ( textCursor, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:OptionTextCursor")
	XuiSendMessage ( textCursor, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (textCursor, 0)
'
'
' *****  OptionFont  *****  XuiFont  *****
'
	XuiFont        (@optFontBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( optFontBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" font ")
	XuiSendMessage ( optFontBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:OptionFont")
	XuiSendMessage ( optFontBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (optFontBox, 0)
'
'
' *****  Memory  *****  XitMemory  *****  Non-Modal
'
	XitMemory      (@memoryBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( memoryBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" memory ")
	XuiSendMessage ( memoryBox, #SetCallback, memoryBox, &DebugMemory(), -1, -1, -1, memoryBox)
	XuiSendMessage ( memoryBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:DebugMemory")
	XuiSendMessage ( memoryBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (memoryBox, 0)
'
'
' *****  Assembly  *****  XitAssembly  *****  Non-Modal
'
	XitAssembly    (@assemblyBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( assemblyBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" assembly ")
	XuiSendMessage ( assemblyBox, #SetCallback, assemblyBox, &DebugAssembly(), -1, -1, -1, assemblyBox)
	XuiSendMessage ( assemblyBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:DebugAssembly")
	XuiSendMessage ( assemblyBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (assemblyBox, 0)
'
'
' *****  Registers  *****  XitRegisters  *****  Non-Modal
'
	XitRegisters   (@registerBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( registerBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" registers ")
	XuiSendMessage ( registerBox, #SetCallback, registerBox, &DebugRegisters(), -1, -1, -1, registerBox)
	XuiSendMessage ( registerBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:DebugRegister")
	XuiSendMessage ( registerBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (registerBox, 0)
'
'
' *****  CompilationErrors  *****  XitErrorCompile  *****  Non-Modal
'
	XitErrorCompile (@errorBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage  ( errorBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" compile errors ")
	XuiSendMessage  ( errorBox, #SetCallback, errorBox, &WizardCompErrors(), -1, -1, -1, errorBox)
	XuiSendMessage  ( errorBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ErrorCompile")
	XuiSendMessage  ( errorBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (errorBox, 0)
'
'
' *****  RuntimeErrors  *****  XitErrorRuntime  *****  Non-Modal
'
	XitErrorRuntime (@runtimeErrorBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage  ( runtimeErrorBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" runtime errors ")
	XuiSendMessage  ( runtimeErrorBox, #SetCallback, runtimeErrorBox, &WizardRunErrors(), -1, -1, -1, runtimeErrorBox)
	XuiSendMessage  ( runtimeErrorBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:ErrorRuntime")
	XuiSendMessage  ( runtimeErrorBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (runtimeErrorBox, 0)
'
'
' ********************************
' *****  HOT BUTTON WIDGETS  *****
' ********************************
'
' *****  Variables  *****  XitVariables  *****  Non-Modal
'
	XitVariables   (@variableBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( variableBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" variables ")
	XuiSendMessage ( variableBox, #SetCallback, variableBox, &HotVariables(), -1, -1, -1, variableBox)
	XuiSendMessage ( variableBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:Variables")
	XuiSendMessage ( variableBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (variableBox, 0)
'
'
' *****  Variable Arrays  *****  XitArray  *****  Non-Modal
'
	XitArray       (@arrayBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( arrayBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" array ")
	XuiSendMessage ( arrayBox, #SetCallback, arrayBox, &VariablesArray(), -1, -1, -1, arrayBox)
	XuiSendMessage ( arrayBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:Array")
	XuiSendMessage ( arrayBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (arrayBox, 0)
'
' *****  Variable Strings  *****  XitString  *****  Non-Modal
'
	XitString      (@stringBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( stringBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" string ")
	XuiSendMessage ( stringBox, #SetCallback, stringBox, &VariablesString(), -1, -1, -1, stringBox)
	XuiSendMessage ( stringBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:String")
	XuiSendMessage ( stringBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (stringBox, 0)
'
'
' *****  Variable Composites  *****  XitComposite  *****  Non-Modal
'
	XitComposite   (@compositeBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( compositeBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" composite ")
	XuiSendMessage ( compositeBox, #SetCallback, compositeBox, &VariablesComposite(), -1, -1, -1, compositeBox)
	XuiSendMessage ( compositeBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:Composite")
	XuiSendMessage ( compositeBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (compositeBox, 0)
'
'
' *****  Frames  *****  XitFrames  *****  Non-Modal
'
	XitFrames      (@framesBox, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( framesBox, #SetWindowTitle, 0, 0, 0, 0, 0, @" frames ")
	XuiSendMessage ( framesBox, #SetCallback, framesBox, &HotFrames(), -1, -1, -1, framesBox)
	XuiSendMessage ( framesBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:Frames")
	XuiSendMessage ( framesBox, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (framesBox, 0)
'
'
' *****  WarningBox  *****  XuiMessage2/3  *****
'
	XuiMessage2B   (@warning2Box, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( warning2Box, #SetWindowTitle, 0, 0, 0, 0, 0, @" warning ")
	XuiSendMessage ( warning2Box, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:Warning2")
	XuiSendMessage ( warning2Box, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (warning2Box, 0)
'
	XuiMessage3B   (@warning3Box, #CreateWindow, x0, y0, 0, 0, windowType, 0)
	XuiSendMessage ( warning3Box, #SetWindowTitle, 0, 0, 0, 0, 0, @" warning ")
	XuiSendMessage ( warning3Box, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:Warning3")
	XuiSendMessage ( warning3Box, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	AlignWindow (warning3Box, 0)
'
'
' ****************************
' *****  Done Box Setup  *****
' ****************************
'
'	Environment Grids:  7/14/93
'		xitGrid  newBox  fileBox  modeBox  renameBox
'		findBox  readBox  writeBox  abandonBox
'		funcBox  viewNewBox  deleteFuncBox  viewRenameBox  viewCloneBox
'		viewLoadBox  viewSaveBox  viewMergeBox
'		optionMiscBox  optTabBox  optFontBox
'		memoryBox  assemblyBox  registerBox
'		errorBox  runtimeErrorBox
'		variableBox  arrayBox  stringBox  compositeBox
'		framesBox
'		warning2Box  warning3Box
'
	DIM popupGrids[63]									' for cursor changes
	i = 0:	popupGrids[i] = newBox
	INC i:	popupGrids[i] = fileBox
	INC i:	popupGrids[i] = modeBox
	INC i:	popupGrids[i] = renameBox
	INC i:	popupGrids[i] = findBox
	INC i:	popupGrids[i] = readBox
	INC i:	popupGrids[i] = writeBox
	INC i:	popupGrids[i] = abandonBox
	INC i:	popupGrids[i] = funcBox
	INC i:	popupGrids[i] = viewNewBox
	INC i:	popupGrids[i] = deleteFuncBox
	INC i:	popupGrids[i] = viewRenameBox
	INC i:	popupGrids[i] = viewCloneBox
	INC i:	popupGrids[i] = viewLoadBox
	INC i:	popupGrids[i] = viewSaveBox
	INC i:	popupGrids[i] = viewMergeBox
	INC i:	popupGrids[i] = optionMiscBox
	INC i:	popupGrids[i] = optTabBox
	INC i:	popupGrids[i] = optFontBox
	INC i:	popupGrids[i] = memoryBox
	INC i:	popupGrids[i] = assemblyBox
	INC i:	popupGrids[i] = registerBox
	INC i:	popupGrids[i] = errorBox
	INC i:	popupGrids[i] = runtimeErrorBox
	INC i:	popupGrids[i] = variableBox
	INC i:	popupGrids[i] = arrayBox
	INC i:	popupGrids[i] = stringBox
	INC i:	popupGrids[i] = compositeBox
	INC i:	popupGrids[i] = framesBox
	INC i:	popupGrids[i] = warning2Box
	INC i:	popupGrids[i] = warning3Box
	REDIM popupGrids[i]
'
'	Turn on message CEO
'
	XgrSetCEO (&XitCEO())
	environmentEntered = $$TRUE
	ClearMessageQueue()
'
' After extensive review, it appears that it may not be
' necessary to initialize the compiler.
'
'	InitializeCompiler ()
'
	XgrSetCursorOverride (entryCursor, 0)
END FUNCTION
'
'
' ############################
' #####  InitWindows ()  #####
' ############################
'
FUNCTION  InitWindows ()
	SHARED  xitGrid
'
	XuiSendMessage (xitGrid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' ############################
' #####  AlignWindow ()  #####
' ############################
'
FUNCTION  AlignWindow (grid, align)
'
	IFZ grid THEN RETURN
	XuiSendMessage (grid, #GetWindowGrid, @gggg, 0, 0, 0, 0, 0)
	IFZ gggg THEN gggg = grid
'	PRINT "########################"
'	PRINT "grid, gggg     = "; HEX$(grid,4);; HEX$(gggg,4)
'	PRINT "displayWidth   = "; HEX$(#displayWidth, 4)
'	PRINT "displayHeight  = "; HEX$(#displayHeight, 4)
'	PRINT "borderWidth    = "; HEX$(#windowBorderWidth, 4)
'	PRINT "titleHeight    = "; HEX$(#windowTitleHeight, 4)
'
	xx = #windowBorderWidth
	yy = #windowBorderWidth + #windowTitleHeight
	XuiSendMessage (gggg, #GetSize, @x, @y, @ww, @hh, 0, 0)
	XuiSendMessage (gggg, #ResizeWindow, xx, yy, ww, hh, 0, 0)
	XuiSendMessage (gggg, #Resize, 0, 0, ww, hh, 0, 0)
	XuiSendMessage (gggg, #GetSize, @x, @y, @ww, @hh, 0, 0)
'	PRINT "xx, yy, ww, hh = "; HEX$(xx,4);; HEX$(yy,4);; HEX$(ww,4);; HEX$(hh,4)

	maxwidth = #displayWidth - #windowBorderWidth - #windowBorderWidth
	maxheight = #displayHeight - #windowBorderWidth - #windowBorderWidth - #windowTitleHeight
'	PRINT "maxwidth, maxheight = "; HEX$(maxwidth,4);; HEX$(maxheight,4)
'
	resize = $$FALSE
	IF (ww > maxwidth) THEN ww = maxwidth : xx = #windowBorderWidth : resize = $$TRUE
	IF (hh > maxheight) THEN hh = maxheight : yy = #windowBorderWidth + #windowTitleHeight : resize = $$TRUE
'
	IF resize THEN
		XuiSendMessage (gggg, #Resize, 0, 0, ww, hh, 0, 0)
		XuiSendMessage (gggg, #GetSize, @x, @y, @w, @h, 0, 0)
	END IF
'	PRINT "xx, yy, ww, hh = "; HEX$(xx,4);; HEX$(yy,4);; HEX$(ww,4);; HEX$(hh,4)
'
	xx = (#displayWidth >> 1) - (ww >> 1)
	yy = (#displayHeight >> 1) - (hh >> 1) - #windowTitleHeight
'
'	PRINT "xx, yy, ww, hh = "; HEX$(xx,4);; HEX$(yy,4);; HEX$(ww,4);; HEX$(hh,4)
	XuiSendMessage (gggg, #ResizeWindow, xx, yy, ww, hh, 0, 0)
'	PRINT "xx, yy, ww, hh = "; HEX$(xx,4);; HEX$(yy,4);; HEX$(ww,4);; HEX$(hh,4)
END FUNCTION
'
'
' ###########################
' #####  HideWindow ()  #####
' ###########################
'
FUNCTION  HideWindow (grid, message, v0, v1, v2, v3, r0, r1)
	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
'	############################
'	#####  Environment ()  #####
'	############################
'
FUNCTION  Environment (grid, message, v0, v1, v2, v3, r0, (r1, r1$, r1[], r1$[]))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR  sub[]
	STATIC  upperMessage
	STATIC  Environment
'
  $Environment          =   0  ' kid   0 grid type = Environment
  $MenuBar              =   1  ' kid   1 grid type = XuiMenu
  $HotProlog            =   2  ' kid   2 grid type = XuiPushButton
  $FileLabel            =   3  ' kid   3 grid type = XuiLabel
  $StatusLabel          =   4  ' kid   4 grid type = XuiLabel
  $HotNew               =   5  ' kid   5 grid type = XuiPushButton
  $HotLoad              =   6  ' kid   6 grid type = XuiPushButton
  $HotSave              =   7  ' kid   7 grid type = XuiPushButton
  $HotSavePlus          =   8  ' kid   8 grid type = XuiPushButton
  $HotCut               =   9  ' kid   9 grid type = XuiPushButton
  $HotCopy              =  10  ' kid  10 grid type = XuiPushButton
  $HotPaste             =  11  ' kid  11 grid type = XuiPushButton
  $HotGui               =  12  ' kid  12 grid type = XuiPushButton
  $HotAbort             =  13  ' kid  13 grid type = XuiPushButton
  $HotFind              =  14  ' kid  14 grid type = XuiPushButton
  $HotReplace           =  15  ' kid  15 grid type = XuiPushButton
  $HotBack              =  16  ' kid  16 grid type = XuiPushButton
  $HotNext              =  17  ' kid  17 grid type = XuiPushButton
  $HotPrevious          =  18  ' kid  18 grid type = XuiPushButton
  $Function             =  19  ' kid  19 grid type = XuiListButton
  $HotStart             =  20  ' kid  20 grid type = XuiPushButton
  $HotContinue          =  21  ' kid  21 grid type = XuiPushButton
  $HotPause             =  22  ' kid  22 grid type = XuiPushButton
  $HotKill              =  23  ' kid  23 grid type = XuiPushButton
  $HotToCursor          =  24  ' kid  24 grid type = XuiPushButton
  $HotStepLocal         =  25  ' kid  25 grid type = XuiPushButton
  $HotStepGlobal        =  26  ' kid  26 grid type = XuiPushButton
  $HotToggleBreakpoint  =  27  ' kid  27 grid type = XuiPushButton
  $HotClearBreakpoints  =  28  ' kid  28 grid type = XuiPushButton
  $HotVariables         =  29  ' kid  29 grid type = XuiPushButton
  $HotFrames            =  30  ' kid  30 grid type = XuiPushButton
  $HotAssembly          =  31  ' kid  31 grid type = XuiPushButton
  $HotRegisters         =  32  ' kid  32 grid type = XuiPushButton
  $HotMemory            =  33  ' kid  33 grid type = XuiPushButton
  $Command              =  34  ' kid  34 grid type = XuiDropBox
  $TextLower            =  35  ' kid  35 grid type = XuiTextArea
  $UpperKid             =  35  ' kid maximum
'
'
	IFZ sub[] THEN GOSUB Initialize
'	XuiReportMessage (grid, message, v0, v1, v2, v3, r0, r1)
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, Environment) THEN RETURN
	IF (message <= upperMessage) THEN GOSUB @sub[message]
	RETURN
'
'
' *****  Callback  *****  message = Callback : r1 = original message
'
SUB Callback
	message = r1
	callback = message
	IF (message <= upperMessage) THEN GOSUB @sub[message]
END SUB
'
'
' *****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, Environment, @v0, @v1, @v2, @v3, r0, r1, &Environment())
	XuiSendMessage ( grid, #SetGridName, 0, 0, 0, 0, 0, @"Environment")
	XuiSendMessage ( grid, #SetBorder, $$BorderNone, $$BorderNone, $$BorderFrame, 0, 0, 0)
	XuiSendMessage ( grid, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:Environment")
	XuiMenu        (@g, #Create, 0, 0, 344, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $MenuBar, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"MenuBar")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderNone, $$BorderNone, $$BorderFrame, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:MenuBar")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"main menu")
	XuiSendMessage ( g, #SetFont, 300, 400, 0, 0, 0, @"Tw Cen MT")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"_file   _edit   _view   _option   _run   _debug   _status   _help")
	DIM text$[68]
	text$[ 0] = "_file   "
	text$[ 1] = " _new"
	text$[ 2] = " _text-load"
	text$[ 3] = " _load"
	text$[ 4] = " _save"
	text$[ 5] = " _mode"
	text$[ 6] = " _rename"
	text$[ 7] = " _quit"
	text$[ 8] = "_edit   "
	text$[ 9] = " _cut"
	text$[10] = " _grab"
	text$[11] = " _paste"
	text$[12] = " _delete"
	text$[13] = " _buffer"
	text$[14] = " _insert"
	text$[15] = " _erase"
	text$[16] = " _find"
	text$[17] = " _read"
	text$[18] = " _write"
	text$[19] = " _abandon"
	text$[20] = "_view   "
	text$[21] = " _function"
	text$[22] = " _prior function"
	text$[23] = " _new function"
	text$[24] = " _delete function"
	text$[25] = " _rename function"
	text$[26] = " _clone function"
	text$[27] = " _load function"
	text$[28] = " _save function"
	text$[29] = " _merge PROLOG"
	text$[30] = " _import function from *.x"
	text$[31] = "_option   "
	text$[32] = " _misc"
	text$[33] = " _color of text-cursor"
	text$[34] = " _tab width (pixels)"
	text$[35] = "_run   "
	text$[36] = " _start"
	text$[37] = " _continue"
	text$[38] = " _jump"
	text$[39] = " _pause"
	text$[40] = " _kill"
	text$[41] = " _erase output"
	text$[42] = " _recompile"
	text$[43] = " _assembly"
	text$[44] = " _library"
	text$[45] = "_debug   "
	text$[46] = " _toggle breakpoint"
	text$[47] = " _clear all breakpoints"
	text$[48] = " _erase local breakpoints"
	text$[49] = " _memory"
	text$[50] = " _assembly"
	text$[51] = " _registers"
	text$[52] = "_status   "
	text$[53] = " _compilation errors"
	text$[54] = " _runtime errors"
	text$[55] = "_help  "
	text$[56] = " _hi"
	text$[57] = " _new"
	text$[58] = " _about"
	text$[59] = " _support"
	text$[60] = " _message"
	text$[61] = " _language"
	text$[62] = " _operator"
	text$[63] = " _dot command"
	text$[64] = " standard library"
	text$[65] = " graphics library"
	text$[66] = " GuiDesigner library"
	text$[67] = " mathematics library"
	text$[68] = " complex number library"
	text$[69] = " network / internet library"
	XuiSendMessage ( g, #SetTextArray, 0, 0, 0, 0, 0, @text$[])
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 1, @"MenuPullDown")
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 1, @"pde.hlp:MenuBar")
	XuiPushButton  (@g, #Create, 344, 0, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotProlog, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotProlog")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotProlog")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"display program PROLOG")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_function_prolog.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiLabel       (@g, #Create, 368, 0, 160, 24, r0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"FileLabel")
	XuiSendMessage ( g, #SetColorExtra, -1, -1, -1, $$LightYellow, 0, 0)
	XuiSendMessage ( g, #SetColor, $$Grey, $$Black, $$Black, $$White, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderNone, $$BorderNone, $$BorderNone, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:FileLabel")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"filename")
	XuiSendMessage ( g, #SetFont, 280, 400, 0, 0, 0, @"Comic Sans MS")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"-filename-")
	XuiLabel       (@g, #Create, 528, 0, 160, 24, r0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"StatusLabel")
	XuiSendMessage ( g, #SetColorExtra, -1, -1, -1, $$LightYellow, 0, 0)
	XuiSendMessage ( g, #SetColor, $$Grey, $$Black, $$Black, $$White, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderNone, $$BorderNone, $$BorderNone, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:StatusLabel")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"status")
	XuiSendMessage ( g, #SetFont, 280, 400, 0, 0, 0, @"Comic Sans MS")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"-status-")
	XuiPushButton  (@g, #Create, 0, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotNew, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotNew")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotNew")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"new program or text-file")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_new.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 24, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotLoad, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotLoad")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotLoad")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"load program or text-file")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_open.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 48, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotSave, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotSave")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotSave")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"save program or text-file")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_save.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 72, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotSavePlus, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotSavePlus")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotSavePlus")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"save new version of program or text-file")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_saveplus.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 104, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotCut, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotCut")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotCut")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"cut selected text, put copy in clipboard")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_cut.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 128, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotCopy, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotCopy")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotCopy")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"copy selected text, put in clipboard")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_copy.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 152, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotPaste, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotPaste")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotPaste")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"paste clipboard text at cursor")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_paste.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 184, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotGui, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotGui")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotGui")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"display/hide GuiDesigner toolkit")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_toolkit.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 208, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotAbort, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotAbort")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotAbort")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"abort executing command")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_stop.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 240, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotFind, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotFind")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotFind")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F11 : find string in program or text-file")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_find.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 264, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotReplace, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotReplace")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotReplace")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F12 : replace string in program or text-file")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_replace.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 296, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotBack, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotBack")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotBack")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"display previous function")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_function_back.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 320, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotNext, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotNext")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotNext")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"display next function")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_function_next.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 344, 24, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotPrevious, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotPrevious")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotPrevious")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"display previously displayed function")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_function_previous.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiListButton  (@g, #Create, 368, 24, 320, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $Function, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"Function")
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, -1, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:Function")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"view function")
	XuiSendMessage ( g, #SetFont, 300, 700, 0, 0, 0, @"Comic Sans MS")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"select function pulldown")
	DIM text$[0]
	text$[0] = "PROLOG or text"
	XuiSendMessage ( g, #SetTextArray, 0, 0, 0, 0, 0, @text$[])
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 1, @"FunctionPressButton")
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 1, @"pde.hlp:Function")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 1, @"view function")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 1, @"select function pulldown")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 2, @"FunctionPullDown")
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 2, @"pde.hlp:Function")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 2, @"view function")
'	DIM text$[0]
'	text$[0] = "PROLOG or text"
'	XuiSendMessage ( g, #SetTextArray, 0, 0, 0, 0, 2, @text$[])
	XuiPushButton  (@g, #Create, 0, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotStart, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotStart")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotStart")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F1 : start program execution from beginning")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_start.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 24, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotContinue, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotContinue")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotContinue")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F2 : continue program execution after pause")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_continue.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 48, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotPause, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotPause")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotPause")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F3 : pause program execution now")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_pause.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 72, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotKill, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotKill")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotKill")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F4 : kill program execution : continue not possible")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_kill.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 104, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotToCursor, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotToCursor")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotToCursor")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F5 : execute program with breakpoint at cursor line")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_step_cursor.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 128, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotStepLocal, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotStepLocal")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotStepLocal")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F6 : execute single-step local - step over called functions")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_step_local.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 152, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotStepGlobal, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotStepGlobal")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotStepGlobal")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F7 : execute single-step global - step into called functions")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_step_global.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 184, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotToggleBreakpoint, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotToggleBreakpoint")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotToggleBreakpoint")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"toggle breakpoint on/off at cursor line")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_breakpoint.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 208, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotClearBreakpoints, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotClearBreakpoints")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotClearBreakpoints")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"clear all breakpoints")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_breakpoints_clear.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 240, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotVariables, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotVariables")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotVariables")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F8 : display variables - view and change values")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_variables.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 264, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotFrames, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotFrames")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotFrames")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F9 : display function call-stack")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_stack.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 296, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotAssembly, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotAssembly")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotAssembly")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"F10 : display assembly language for cursor line")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_assembly.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 320, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotRegisters, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotRegisters")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotRegisters")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"display CPU registers")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_registers.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiPushButton  (@g, #Create, 344, 48, 24, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $HotMemory, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HotMemory")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetBorder, $$BorderFlat1, $$BorderFlat1, $$BorderLower1, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 0, @"pde.hlp:HotMemory")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"display memory")
	XuiSendMessage ( g, #SetImage, 0, 0, 4, 4, 0, @"$XBDIR/images/icon_memory.bmp")
	XuiSendMessage ( g, #SetImageCoords, 0, 0, 16, 16, 0, 0)
	XuiDropBox     (@g, #Create, 368, 48, 320, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $Command, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"Command")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:Command")
'	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 0, @"enter dot commands here")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @".c enter dot commands here")
	DIM text$[15]
	text$[ 0] = ".c enter dot commands here"
	text$[ 1] = ".fl filename"
	text$[ 2] = ".ft filename"
	text$[ 3] = ".fs filename"
	text$[ 4] = ".fq"
	text$[ 5] = ".v funcname"
	text$[ 6] = ".v PROLOG"
	text$[ 7] = ".vp"
	text$[ 8] = ".v-"
	text$[ 9] = ".v"
	text$[10] = ".rs"
	text$[11] = ".rr"
	text$[12] = ".rk"
	text$[13] = ".h"
	text$[14] = ".f findstring"
	text$[15] = ".r findstring replacestring"
	XuiSendMessage ( g, #SetTextArray, 0, 0, 0, 0, 0, @text$[])
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 1, @"CommandTextLine")
	XuiSendMessage ( g, #SetColorExtra, $$LightYellow, $$LightYellow, $$Black, $$White, 1, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 1, @"pde.hlp:Command")
'	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 1, @"enter dot commands here")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 1, @".c enter dot commands here")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 2, @"CommandPressButton")
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 2, @"pde.hlp:Command")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 2, @"show command list")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 3, @"CommandPullDown")
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 3, @"pde.hlp:Command")
	XuiSendMessage ( g, #SetHintString, 0, 0, 0, 0, 3, @"select command")
'	DIM text$[15]
'	text$[ 0] = ".c enter dot commands here"
'	text$[ 1] = ".fl filename"
'	text$[ 2] = ".ft filename"
'	text$[ 3] = ".fs filename"
'	text$[ 4] = ".fq"
'	text$[ 5] = ".v funcname"
'	text$[ 6] = ".v PROLOG"
'	text$[ 7] = ".vp"
'	text$[ 8] = ".v-"
'	text$[ 9] = ".v"
'	text$[10] = ".rs"
'	text$[11] = ".rr"
'	text$[12] = ".rk"
'	text$[13] = ".h"
'	text$[14] = ".f findstring"
'	text$[15] = ".r findstring replacestring"
'	XuiSendMessage ( g, #SetTextArray, 0, 0, 0, 0, 3, @text$[])
	XuiTextArea    (@g, #Create, 0, 72, 688, 128, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Environment(), -1, -1, $TextLower, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"TextLower")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:TextLower")
'	XuiSendMessage ( g, #SetHintString, -1, 0, 0, 0, 0, @"program or text")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 1, @"Text")
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 1, @"pde.hlp:TextLower")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 2, @"ScrollH")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 2, 0)
	XuiSendMessage ( g, #SetColor, 19, -1, -1, -1, 2, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 2, @"pde.hlp:TextLower")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 3, @"ScrollV")
	XuiSendMessage ( g, #SetStyle, 2, 0, 0, 0, 3, 0)
	XuiSendMessage ( g, #SetColor, 19, -1, -1, -1, 3, 0)
	XuiSendMessage ( g, #SetHelpString, 0, 0, 0, 0, 3, @"pde.hlp:TextLower")
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Environment")
END SUB
'
'
' *****  GetSmallestSize  *****  see "Anatomy of Grid Functions"
'
SUB GetSmallestSize
	v2 = designWidth
	v3 = designHeight
END SUB
'
'
' *****  Resize  *****  see "Anatomy of Grid Functions"
'
SUB Resize
	vv2 = v2
	vv3 = v3
	GOSUB GetSmallestSize
	IF (v2 < vv2) THEN v2 = vv2
	IF (v3 < vv3) THEN v3 = vv3
'
' position and size main/parent grid
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
'
' make sure we have a plausibly compact font in the menu bar
'
	XuiSendMessage ( grid, #GetFontNumber, @font, 0, 0, 0, $MenuBar, 0)
	IFZ font THEN XuiSendMessage ( grid, #GetFontNumber, @font, 0, 0, 0, $MenuBar, 0)
	IFZ font THEN XuiSendMessage ( grid, #SetFont, 280, 400, 0, 0, $MenuBar, @"MS Sans Serif")
	IFZ font THEN XuiSendMessage ( grid, #GetFontNumber, @font, 0, 0, 0, $MenuBar, 0)
	IFZ font THEN XuiSendMessage ( grid, #SetFont, 260, 400, 0, 0, $MenuBar, @"Arial")
	IFZ font THEN XuiSendMessage ( grid, #GetFontNumber, @font, 0, 0, 0, $MenuBar, 0)
	IFZ font THEN XuiSendMessage ( grid, #SetFont, 260, 400, 0, 0, $MenuBar, @"Comic Sans MS")
	IFZ font THEN XuiSendMessage ( grid, #GetFontNumber, @font, 0, 0, 0, $MenuBar, 0)
	IFZ font THEN XuiSendMessage ( grid, #SetFont, 260, 400, 0, 0, $MenuBar, @"Helvetica")
	IFZ font THEN XuiSendMessage ( grid, #GetFontNumber, @font, 0, 0, 0, $MenuBar, 0)
	IFZ font THEN XuiSendMessage ( grid, #SetFont, 260, 400, 0, 0, $MenuBar, @"Helv")
	IFZ font THEN XuiSendMessage ( grid, #GetFontNumber, @font, 0, 0, 0, $MenuBar, 0)
	IFZ font THEN XuiSendMessage ( grid, #SetFont, 300, 400, 0, 0, $MenuBar, @"Tw Cen MT")
'
	XuiSendMessage (grid, #SetFontNumber, font, 0, 0, 0, $FileLabel, 0)
	XuiSendMessage (grid, #SetFontNumber, font, 0, 0, 0, $StatusLabel, 0)
'
	XuiGetSize (grid, #GetSize, @xx, @yy, @ww, @hh, $Environment, 0)	' whole window
	XuiGetSize (grid, #GetSize, @tx, @ty, @tw, @th, $TextLower, 0)		' program text
	XuiGetSize (grid, #GetSize, @fx, @fy, @fw, @fh, $Function, 0)			' function
'
	xw0 = v2 - fx									' space to right of menu-bar & buttons
	xw1 = xw0 >> 1								' width of left-hand button
	xw2 = xw0 - xw1								' width of right-hand button
	sx = fx + xw1									' x position of right-hand button
	th = v3 - ty									' new height of program text
'
'	PRINT v0; v1; v2; v3;; fx; sx; tx;;; xw0; xw1; xw2;;; xx; yy; ww; hh
'
	XuiSendMessage (grid, #Resize, fx,  0, xw1, 24, $FileLabel, 0)
	XuiSendMessage (grid, #Resize, sx,  0, xw2, 24, $StatusLabel, 0)
	XuiSendMessage (grid, #Resize, fx, 24, xw0, 24, $Function, 0)
	XuiSendMessage (grid, #Resize, fx, 48, xw0, 24, $Command, 0)
	XuiSendMessage (grid, #Resize, tx, ty,  v2, th, $TextLower, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Selection  *****  see "Anatomy of Grid Functions"
'
SUB Selection
END SUB
'
'
' *****  Initialize  *****  ' see "Anatomy of Grid Functions"
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	XgrMessageNameToNumber (@"LastMessage", @upperMessage)
'
	func[#Callback]           = &XuiCallback ()               ' disable to handle Callback messages internally
	func[#GetSmallestSize]    = 0                             ' enable to add internal GetSmallestSize routine
	func[#GotKeyboardFocus]   = &XuiGotKeyboardFocus()
	func[#LostKeyboardFocus]  = &XuiLostKeyboardFocus()
	func[#Resize]             = 0                             ' enable to add internal Resize routine
	func[#SetKeyboardFocus]   = &XuiSetKeyboardFocus()
'
	DIM sub[upperMessage]
'	sub[#Callback]            = SUBADDRESS (Callback)         ' enable to handle Callback messages internally
	sub[#Create]              = SUBADDRESS (Create)           ' must be internal routine
	sub[#CreateWindow]        = SUBADDRESS (CreateWindow)     ' must be internal routine
	sub[#GetSmallestSize]     = SUBADDRESS (GetSmallestSize)  ' enable to add internal GetSmallestSize routine
	sub[#Resize]              = SUBADDRESS (Resize)           ' enable to add internal Resize routine
	sub[#Selection]           = SUBADDRESS (Selection)        ' routes Selection callbacks to subroutine
'
	IF sub[0] THEN PRINT "Environment() : Initialize : error ::: (undefined message)"
	IF func[0] THEN PRINT "Environment() : Initialize : error ::: (undefined message)"
	XuiRegisterGridType (@Environment, "Environment", &Environment(), @func[], @sub[])
'
' Don't remove the following 4 lines, or WindowFromFunction/WindowToFunction will not work
'
	designX = 908
	designY = 623
	designWidth = 632
	designHeight = 200
'
	gridType = Environment
	XuiSetGridTypeProperty (gridType, @"x",                designX)
	XuiSetGridTypeProperty (gridType, @"y",                designY)
	XuiSetGridTypeProperty (gridType, @"width",            designWidth)
	XuiSetGridTypeProperty (gridType, @"height",           designHeight)
'	XuiSetGridTypeProperty (gridType, @"maxWidth",         designWidth)
'	XuiSetGridTypeProperty (gridType, @"maxHeight",        designHeight)
	XuiSetGridTypeProperty (gridType, @"minWidth",         designWidth)
	XuiSetGridTypeProperty (gridType, @"minHeight",        designHeight)
	XuiSetGridTypeProperty (gridType, @"can",              $$Focus OR $$Respond OR $$Callback OR $$InputTextString OR $$InputTextArray OR $$TextSelection)
	XuiSetGridTypeProperty (gridType, @"focusKid",         $TextLower)
	XuiSetGridTypeProperty (gridType, @"inputTextArray",   $TextLower)
	XuiSetGridTypeProperty (gridType, @"inputTextString",  $Command)
	XuiSetGridTypeProperty (gridType, @"redrawFlags",      $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
' ################################
' #####  EnvironmentCode ()  #####
' ################################
'
FUNCTION  EnvironmentCode (grid, message, v0, v1, v2, v3, r0, (r1, r1$, r1$[]))
	SHARED  fileType,  programAltered,  softInterrupt
	SHARED  editFunction,  blowback
	SHARED  haltedByEdit,  textAlteredSinceLastSave
	SHARED  funcAltered[],  funcNeedsTokenizing[]
	SHARED  findBox,  funcBox,  deleteFuncBox,  viewNewBox
	SHARED  optionMiscBox,  memoryBox,  assemblyBox,  registerBox
	SHARED  errorBox,  runtimeErrorBox,  framesBox
	SHARED  variableBox
	SHARED  welcomeGrid
	SHARED  timeExpired
	SHARED  textCursor
'
  $Environment          =   0  ' kid   0 grid type = Environment
  $MenuBar              =   1  ' kid   1 grid type = XuiMenu
  $HotProlog            =   2  ' kid   2 grid type = XuiPushButton
  $FileLabel            =   3  ' kid   3 grid type = XuiLabel
  $StatusLabel          =   4  ' kid   4 grid type = XuiLabel
  $HotNew               =   5  ' kid   5 grid type = XuiPushButton
  $HotLoad              =   6  ' kid   6 grid type = XuiPushButton
  $HotSave              =   7  ' kid   7 grid type = XuiPushButton
  $HotSavePlus          =   8  ' kid   8 grid type = XuiPushButton
  $HotCut               =   9  ' kid   9 grid type = XuiPushButton
  $HotCopy              =  10  ' kid  10 grid type = XuiPushButton
  $HotPaste             =  11  ' kid  11 grid type = XuiPushButton
  $HotGui               =  12  ' kid  12 grid type = XuiPushButton
  $HotAbort             =  13  ' kid  13 grid type = XuiPushButton
  $HotFind              =  14  ' kid  14 grid type = XuiPushButton
  $HotReplace           =  15  ' kid  15 grid type = XuiPushButton
  $HotBack              =  16  ' kid  16 grid type = XuiPushButton
  $HotNext              =  17  ' kid  17 grid type = XuiPushButton
  $HotPrevious          =  18  ' kid  18 grid type = XuiPushButton
  $Function             =  19  ' kid  19 grid type = XuiListButton
  $HotStart             =  20  ' kid  20 grid type = XuiPushButton
  $HotContinue          =  21  ' kid  21 grid type = XuiPushButton
  $HotPause             =  22  ' kid  22 grid type = XuiPushButton
  $HotKill              =  23  ' kid  23 grid type = XuiPushButton
  $HotToCursor          =  24  ' kid  24 grid type = XuiPushButton
  $HotStepLocal         =  25  ' kid  25 grid type = XuiPushButton
  $HotStepGlobal        =  26  ' kid  26 grid type = XuiPushButton
  $HotToggleBreakpoint  =  27  ' kid  27 grid type = XuiPushButton
  $HotClearBreakpoints  =  28  ' kid  28 grid type = XuiPushButton
  $HotVariables         =  29  ' kid  29 grid type = XuiPushButton
  $HotFrames            =  30  ' kid  30 grid type = XuiPushButton
  $HotAssembly          =  31  ' kid  31 grid type = XuiPushButton
  $HotRegisters         =  32  ' kid  32 grid type = XuiPushButton
  $HotMemory            =  33  ' kid  33 grid type = XuiPushButton
  $Command              =  34  ' kid  34 grid type = XuiDropBox
  $TextLower            =  35  ' kid  35 grid type = XuiTextArea
  $UpperKid             =  35  ' kid maximum
'
'	XgrMessageNumberToName (message, @message$)
'	PRINT "EnvironmentCode() : "; grid, message$, v0, v1, v2, v3, r0, r1
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #Selection			: GOSUB Selection
		CASE #TextEvent			: GOSUB TextEvent
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	callback = message
	SELECT CASE message
		CASE #CloseWindow	: GOSUB CloseWindow
		CASE #Notify			: GOSUB Notify
		CASE #Selection		:	GOSUB Selection
		CASE #TextEvent		:	GOSUB TextEvent
	END SELECT
END SUB
'
'
' *****  CloseWindow  *****
'
SUB CloseWindow
	FileQuit ()
END SUB
'
'
' *****  Notify  *****  from XuiDropButton grid that displays function-list
'
SUB Notify
	IF (r0 != $Function) THEN EXIT SUB															' bad kid
	IF (fileType != $$Program) THEN EXIT SUB												' ingore text
	items = SortFunctionNames (@name$[], $$TRUE)										' include PROLOG
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, r0, @name$[])	' set function names
END SUB
'
'
' *****  Selection  *****  r0 = kid : xitMenu:  v0 = Menu heading # (1+) and v1 = pulldown entry (0+)
'
SUB Selection
	IF timeExpired THEN EXIT SUB
	SELECT CASE r0
		CASE $HotProlog						: immediate$ = ".vv PROLOG"
																GOSUB Immediate
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
		CASE $HotNew							: FileNew(0)
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
		CASE $HotLoad							: FileLoad(0)
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
		CASE $HotSave							: FileSave(0)
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
		CASE $HotSavePlus					: FileSave(0)
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
		CASE $HotCut							: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $TextLower, 0)
																EditCut(0)
		CASE $HotCopy							: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $TextLower, 0)
																EditGrab(0)
		CASE $HotPaste						: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $TextLower, 0)
																EditPaste(0)
		CASE $HotGui							: XxxGuiDesignerOnOff (1)
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
		CASE $HotAbort						: softInterrupt = $$TRUE
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
		CASE $HotFind							: button = v2{3,0}
																message = #FindForward
																IF (button = 2) THEN message = #FindReverse
																IF (v2 AND ($$CtrlBit OR $$ShiftBit)) THEN message = #FindReverse
																EditFind (findBox, message, 0, 0, 0, 0, 0, 0)
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $TextLower, 0)
		CASE $HotReplace					: button = v2{4,0}
																message = #ReplaceForward
																IF (button = 2) THEN message = #ReplaceReverse
																IF (v2 AND ($$CtrlBit OR $$ShiftBit)) THEN message = #ReplaceReverse
																EditFind (findBox, message, 0, 0, 0, 0, 0, 0)
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $TextLower, 0)
		CASE $HotBack							: immediate$ = ".v-"
																GOSUB Immediate
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
		CASE $HotNext							: immediate$ = ".v"
																GOSUB Immediate
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
		CASE $HotPrevious					: immediate$ = ".vp"
																GOSUB Immediate
																XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
		CASE $HotStart						: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																RunStart()
		CASE $HotContinue					: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																RunContinue()
		CASE $HotPause						: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																RunPause()
		CASE $HotKill							: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																RunKill()
		CASE $HotToCursor					: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																HotToCursor()
		CASE $HotStepLocal				: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																HotStepLocal()
		CASE $HotStepGlobal				: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																HotStepGlobal()
		CASE $HotToggleBreakpoint	: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																DebugToggle()
		CASE $HotClearBreakpoints	: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																DebugClear()
		CASE $HotVariables				: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																HotVariables (variableBox, #DisplayWindow, $$TRUE, 0, 0, 0, 0, 0)
		CASE $HotFrames						: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																HotFrames (framesBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		CASE $HotAssembly					: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																DebugAssembly (assemblyBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		CASE $HotRegisters				: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																DebugRegisters (registerBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		CASE $HotMemory						: XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																XuiSendMessage (memoryBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		CASE $TextLower						: IF (v0{$$VirtualKey} = $$KeyEscape) THEN
																	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $Command, "")
																	XuiSendMessage (grid, #SetTextCursor, 0, 0, 0, 0, $Command, 0)
																	XuiSendMessage (grid, #Redraw, 0, 0, 0, 0, $Command, 0)
																	XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $Command, 0)
																END IF
		CASE $Function						: GOSUB Function
		CASE $Command							: GOSUB Command
		CASE $MenuBar
				IF ((v0 < 1) OR (v1 < 0)) THEN RETURN
				SELECT CASE v0
					CASE 1
							SELECT CASE v1
								CASE 0:		FileNew (0)
								CASE 1:		FileTextLoad (0)
								CASE 2:		FileLoad (0)
								CASE 3:		FileSave (0)
								CASE 4:		FileMode (0)
								CASE 5:		FileRename (0)
								CASE 6:		FileQuit ()
							END SELECT
					CASE 2
							SELECT CASE v1
								CASE 0:		EditCut (0)
								CASE 1:		EditGrab (0)
								CASE 2:		EditPaste (0)
								CASE 3:		EditCut (1)
								CASE 4:		EditGrab (1)
								CASE 5:		EditPaste (1)
								CASE 6:		EditCut (-1)
								CASE 7:		EditFind (findBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
								CASE 8:		EditRead (0)
								CASE 9:		EditWrite (0)
								CASE 10:	EditAbandon ()
							END SELECT
					CASE 3
							SELECT CASE v1
								CASE 0:		ViewFunc (funcBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
								CASE 1:		ViewPriorFunc ()
								CASE 2:		ViewNewFunc (viewNewBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
								CASE 3:		ViewDeleteFunc (deleteFuncBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
								CASE 4:		ViewRenameFunc (0)
								CASE 5:		ViewCloneFunc (0)
								CASE 6:		ViewLoadFunc (0)
								CASE 7:		ViewSaveFunc (0)
								CASE 8:		ViewMergePROLOG (0)
								CASE 9:		ViewImportFunctionFromProgram (0)
							END SELECT
					CASE 4
							SELECT CASE v1
								CASE 0:		XuiSendMessage (optionMiscBox, #ShowWindow, 0, 0, 0, 0, 0, 0)
								CASE 1:		XuiSendMessage (textCursor, #ShowWindow, 0, 0, 0, 0, 0, 0)
								CASE 2:		OptionTabWidth (0)
								CASE 3:		OptionFont ()
							END SELECT
					CASE 5
							SELECT CASE v1
								CASE 0:		RunStart ()
								CASE 1:		RunContinue ()
								CASE 2:		RunJump ()
								CASE 3:		RunPause ()
								CASE 4:		RunKill ()
								CASE 5:		XstClearConsole ()
								CASE 6:		RunRecompile ()
								CASE 7:		RunAssembly ()
								CASE 8:		RunLibrary ()
							END SELECT
					CASE 6
							SELECT CASE v1
								CASE 0:		DebugToggle ()
								CASE 1:		DebugClear ()
								CASE 2:		DebugErase ()
								CASE 3:		XuiSendMessage (memoryBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
								CASE 4:		DebugAssembly (assemblyBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
								CASE 5:		DebugRegisters (registerBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
							END SELECT
					CASE 7
							SELECT CASE v1
								CASE 0:		WizardCompErrors (errorBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
								CASE 1:		XuiSendMessage (runtimeErrorBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
							END SELECT
					CASE 8
							SELECT CASE v1
								CASE  0:
									IF ##XBSystem = $$XBSysLinux THEN
										XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/README.Linux:*")
									ELSE
										XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/README.Win32:*")
									END IF
								CASE  1:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/help/new.hlp:*")
								CASE  2:	XuiSendMessage (welcomeGrid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
								CASE  3:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/help/support.hlp:*")
								CASE  4:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/help/message.hlp:*")
								CASE  5:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/help/language.hlp:*")
								CASE  6:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/help/operator.hlp:*")
								CASE  7:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/help/command.hlp:*")
								CASE  8:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/include/xst.dec:*")
								CASE  9:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/include/xgr.dec:*")
								CASE 10:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/include/xui.dec:*")
								CASE 11:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/include/xma.dec:*")
								CASE 12:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/include/xcm.dec:*")
								CASE 13:	XuiSendMessage (grid, #SetHelp, 0, 0, 0, 0, 0, "$XBDIR/include/xin.dec:*")
							END SELECT
				END SELECT
	END SELECT
END SUB
'
'
' *****  Immediate  *****
'
SUB Immediate
	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $Command, @immediate$)
	ImmediateMode (0x0D10000D)
	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $Command, "")
	XuiSendMessage (grid, #Redraw, 0, 0, 0, 0, $Command, 0)
END SUB
'
'
' *****  Function  *****  display selected function
'
SUB Function
'	PRINT "EnvironmentCode() : Function : "; grid, message, v0, v1, v2, v3, r0, r1
'
	IF (fileType != $$Program) THEN EXIT SUB												' text file
	IF (v0 < 0) THEN EXIT SUB																				' nothing
'
	XuiSendMessage (grid, #GetTextArray, 0, 0, 0, 0, r0, @funcname$[])
'
	funcname$ = ""
	upper = UBOUND (funcname$[])
	IF (v0 <= upper) THEN funcname$ = funcname$[v0]
	IFZ funcname$ THEN EXIT SUB
'
	ViewFunc (funcBox, #View, 0, 0, 0, 0, 0, @funcname$)
END SUB
'
'
' *****  Command  *****  immediate command selected from list
'
SUB Command
	XuiSendMessage (grid, #GetTextArray, 0, 0, 0, 0, r0, @command$[])
	XuiSendMessage (grid, #GetTextString, 0, 0, 0, 0, r0, @command$)
	upper = UBOUND (command$[])
'
'	PRINT "EnvironmentCode().Command.a :::  "; grid; message; v0; v1; v2; v3; r0; r1, HEX$(v2,8), upper;; command$
'
'	IF (v0 == -1) THEN
'		PRINT "EnvironmentCode().Command.b :::  "; grid; message; v0; v1; v2; v3; r0; r1, HEX$(v2,8), upper;; command$
'		ImmediateMode (0x0D10000D)
'	END IF
'
	IF (v0 >= 0) AND (v0 <= upper) THEN
		command$ = command$[v0]
'		PRINT "EnvironmentCode().Command.c :::  "; grid; message; v0; v1; v2; v3; r0; r1, HEX$(v2,8), upper;; command$
		AddCommandItem (@command$)
'		XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, r0, @command$)
'		XuiSendMessage (grid, #Redraw, 0, 0, 0, 0, r0, 0)
'		ImmediateMode (0x0D10000D)
	END IF
'
'	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, r0, "")
'	XuiSendMessage (grid, #Redraw, 0, 0, 0, 0, r0, 0)
END SUB
'
'
' *****  TextEvent  *****  Changes while running halts run
'
SUB TextEvent
'	PRINT "::: TextEvent :::  "; grid, message, v0, v1, v2, v3, r0, r1, $Command, $TextLower, HEX$(v2,8), HEX$($$KeyEnter,8)
	IF (r0 == $Command) THEN
		IF (v2{$$VirtualKey} == $$KeyEnter) THEN
			XuiSendMessage (grid, #GetTextString, 0, 0, 0, 0, $Command, @command$)
			AddCommandItem (@command$)
			ImmediateMode (v2)
			r0 = -1
		END IF
		IF (v2{$$VirtualKey} == $$KeyEscape) THEN
			XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $TextLower, 0)
			r0 = -1
		END IF
		EXIT SUB
	END IF
'
	IF (r0 != $TextLower) THEN EXIT SUB
	XgrGetKeystateModify (v2, @modify, @edit)
	IFZ modify THEN EXIT SUB
'
	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $Command, "")
	XuiSendMessage (grid, #Redraw, 0, 0, 0, 0, $Command, 0)
'
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		message$ = "??? terminate program execution ???"
		warningResponse = WarningResponse (@message$, @" terminate ", "")
		IF (warningResponse = $$WarningCancel) THEN
			r0 = -1																		' abort modification
			EXIT SUB
		END IF
'
'		Cannot allow text edit before blowback
'
		haltedByEdit = $$TRUE
		XxxSetBlowback ()
		r0 = -1
		EXIT SUB
	END IF
'
	IFZ textAlteredSinceLastSave THEN
		textAlteredSinceLastSave = $$TRUE
		UpdateFileFuncLabels ($$TRUE, 0)						' reset file name
	END IF
	IF (fileType != $$Program) THEN EXIT SUB			' done if Text mode
'
' By modifying the text, the user is forced to recompile before running
'
	IFZ programAltered THEN
		programAltered = $$TRUE
		AddDispatch (&ResetDataDisplays(), $$ResetAssembly)
	END IF
	funcAltered[editFunction] = $$TRUE
	funcNeedsTokenizing[editFunction] = $$TRUE
'
'
'	Blowback done this way to allow text edit to be completed.
'	OOPS - cannot insert text edit before blowback.
'
'	IF ##USERRUNNING THEN
'		haltedByEdit = $$TRUE
'		XxxSetBlowback ()
'	END IF
END SUB
END FUNCTION
'
'
' ##################################
' #####  WelcomeWindowCode ()  #####
' ##################################
'
FUNCTION  WelcomeWindowCode (grid, message, v0, v1, v2, v3, r0, r1)
'
	IF (message == #Callback) THEN message = r1
'
	SELECT CASE message
		CASE #Selection			: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
	END SELECT
END FUNCTION
'
'
' #######################  processes system messages only
' #####  XitCEO ()  #####  #WindowKeyDown: v2 = state
' #######################
'
FUNCTION  XitCEO (winGrid, message, v0, v1, v2, v3, r0, r1)
	SHARED  xitGrid,  xitTextLower,  xitCommand
	SHARED  assemblyBox,  findBox,  framesBox,  variableBox
'
'	XgrMessageNumberToName (message, @message$)
'	PRINT "XitCEO() : "; winGrid, message$, v0, v1, HEX$(v2,8), HEX$(v3,8), r0, r1
'
	SELECT CASE message
		CASE  #WindowKeyDown
			ctrl = v2 AND $$CtrlBit
			shift = v2 AND $$ShiftBit
			SELECT CASE v2{$$VirtualKey}
				CASE $$KeyF1		:	RunStart()
				CASE $$KeyF2		:	RunContinue()
				CASE $$KeyF3		:	RunPause()
				CASE $$KeyF4		:	RunKill()
				CASE $$KeyF5		:	HotToCursor()
				CASE $$KeyF6		:	HotStepLocal()
				CASE $$KeyF7		:	HotStepGlobal()
				CASE $$KeyF8		:	HotVariables (variableBox, #DisplayWindow, $$TRUE, 0, 0, 0, 0, 0)
				CASE $$KeyF9		:	HotFrames (framesBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
				CASE $$KeyF10		:	DebugAssembly (assemblyBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
				CASE $$KeyF11		:	message = #FindForward
													IF (ctrl OR shift) THEN message = #FindReverse
													EditFind (findBox, message, 0, 0, 0, 0, 0, 0)
				CASE $$KeyF12		:	message = #ReplaceForward
													IF (ctrl OR shift) THEN message = #ReplaceReverse
													EditFind (findBox, message, 0, 0, 0, 0, 0, 0)
				CASE $$KeyPause	:	XitSoftBreak()
			END SELECT
	END SELECT
END FUNCTION
'
'
' #########################
' #####  XitArray ()  #####
' #########################
'
FUNCTION  XitArray (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR	 sub[]
	STATIC  upperMessage
	STATIC  XitArray
'
	$functionLabel	= 1
	$symbolLabel		= 2
	$columnLabel		= 3
	$list						= 4
	$higherButton		= 5
	$lowerButton		= 6
	$indexLabel			= 7
	$indexText			= 8
	$elementLabel		= 9
	$elementText		= 10
	$button0				= 11
	$button1				= 12
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitArray) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh in window : r0 = window
'
SUB Create
  IF (v0 <= 0) THEN v0 = 0
  IF (v1 <= 0) THEN v1 = 0
  IF (v2 <= 0) THEN v2 = designWidth
  IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, XitArray, v0, v1, v2, v3, r0, r1, &XitArray())
	XuiLabel       (@g, #Create, 4, 4, 536, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiLabel       (@g, #Create, 4, 24, 536, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiLabel       (@g, #Create, 4, 44, 536, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"index       location     hex               value")
	XuiList        (@g, #Create, 4, 64, 536, 120, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitArray(), -1, -1, $list, grid)
	XuiPushButton  (@g, #Create, 4, 184, 268, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitArray(), -1, -1, $higherButton, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"<<<  next higher dimension <<<")
	XuiPushButton  (@g, #Create, 272, 184, 268, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitArray(), -1, -1, $lowerButton, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @">>>  next lower dimension >>>")
	XuiLabel       (@g, #Create, 4, 204, 224, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"view index [0-##########]  ")
	XuiTextLine    (@g, #Create, 4, 224, 224, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitArray(), -1, -1, $indexText, grid)
	XuiLabel       (@g, #Create, 228, 204, 312, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"view element [i,j,]")
	XuiTextLine    (@g, #Create, 228, 224, 312, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitArray(), -1, -1, $elementText, grid)
	XuiPushButton  (@g, #Create, 4, 244, 268, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitArray(), -1, -1, $button0, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" detail ")
	XuiPushButton  (@g, #Create, 272, 244, 268, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitArray(), -1, -1, $button1, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****   v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Array Detail")
END SUB
'
'
' *****  GetSmallestSize  *****  Return v23 = smallest wh
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	bw = border
'
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @functionLabelWidth, @functionLabelHeight, $functionLabel, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @symbolLabelWidth, @symbolLabelHeight, $symbolLabel, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @columnLabelWidth, @columnLabelHeight, $columnLabel, 16)
'
	XuiSendToKid (grid, #GetSmallestSize, 20, 4, @listWidth, @listHeight, $list, 16)
'
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @higherButtonWidth, @higherButtonHeight, $higherButton, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @lowerButtonWidth, @lowerButtonHeight, $lowerButton, 16)
'
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @indexLabelWidth, @indexLabelHeight, $indexLabel, 8)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, 0, @indexTextHeight, $indexText, 8)
'
	buttonWidth = 12
	buttonHeight = 12
	FOR i = $button0 TO $button1
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 12)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
	width = functionLabelWidth
	IF (width < symbolLabelWidth) THEN width = symbolLabelWidth
	IF (width < columnLabelWidth) THEN width = columnLabelWidth
	whilo = higherButtonWidth + lowerButtonWidth
	IF (width < whilo) THEN width = whilo
	wb0b1 = buttonWidth + buttonWidth
	IF (width < wb0b1) THEN width = wb0b1
	IF (width < listWidth) THEN width = listWidth
	v2 = width + bw + bw
	v3 = functionLabelHeight + symbolLabelHeight + columnLabelHeight
	v3 = v3 + listHeight + higherButtonHeight
	v3 = v3 + indexLabelHeight + indexTextHeight
	v3 = v3 + buttonHeight + bw + bw
	minW = v2
	minH = v3
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize				' returns bw and heights
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	h = minH
'
	IF (v3 > (h + 4)) THEN
		buttonHeight = buttonHeight + 4									:	h = h + 4
		IF (v3 > (h + 12)) THEN
			functionLabelHeight = functionLabelHeight + 4	:	h = h + 12
			symbolLabelHeight = symbolLabelHeight + 4
			columnLabelHeight = columnLabelHeight + 4
			IF (v3 > (h + 4)) THEN
				higherButtonHeight = higherButtonHeight + 4	:	h = h + 4
				IF (v3 > (h + 8)) THEN
					indexLabelHeight = indexLabelHeight + 4
					indexTextHeight = indexTextHeight + 4
				END IF
			END IF
		END IF
	END IF
'
'	Resize kids
'
	x = bw
	y = bw
	w = v2 - bw - bw
	h = functionLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $functionLabel, 0)
'
	y = y + h
	h = symbolLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $symbolLabel, 0)
'
	y = y + h
	h = columnLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $columnLabel, 0)
'
	y = y + h
	h = v3 - functionLabelHeight - symbolLabelHeight - columnLabelHeight
	h = h - higherButtonHeight - indexLabelHeight - indexTextHeight
	h = h - buttonHeight - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w, h, $list, 0)
'
	y = y + h
	w = w >> 1
	h = higherButtonHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $higherButton, 0)
	x = x + w
	w = v2 - w - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w, h, $lowerButton, 0)
'
	x = bw
	y = y + h
	w = indexLabelWidth
	h = indexLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $indexLabel, 0)
	y = y + h
	h = indexTextHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $indexText, 0)
'
	x = x + w
	y = y - indexLabelHeight
	w = v2 - indexLabelWidth - bw - bw
	h = indexLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $elementLabel, 0)
	y = y + h
	h = indexTextHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $elementText, 0)
'
	x = bw
	y = y + h
	h = buttonHeight
	w1 = (v2 - bw - bw) >> 1
	w2 = v2 - w1 - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w2, h, $button0, 0) : x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button1, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#GotKeyboardFocus]		= &XuiGotKeyboardFocus()
	func[#LostKeyboardFocus]	= &XuiLostKeyboardFocus()
	func[#Resize]							= 0
	func[#SetKeyboardFocus]		= &XuiSetKeyboardFocus()
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitArray() : Initialize: error ::: undefined message"
	IF sub[0] THEN PRINT "XitArray() : Initialize: error ::: undefined message"
	XuiRegisterGridType (@XitArray, @"XitArray", &XitArray(), @func[], @sub[])
'
	designX = 0
	designY = 0
	designWidth = 544
	designHeight = 268
'
	gridType = XitArray
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Respond OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $indexText)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ############################
' #####  XitAssembly ()  #####
' ############################
'
FUNCTION  XitAssembly (grid, message, v0, v1, v2, v3, r0, (r1, r1$, r1$[]))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR	 sub[]
	STATIC  upperMessage
	STATIC  XitAssembly
'
	$label		= 1
	$textArea	= 2
	$button0	= 3
	$button1	= 4
	$button2	= 5
	$button3	= 6
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitAssembly) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, XitAssembly, @v0, @v1, @v2, @v3, r0, r1, &XitAssembly())
	XuiLabel       (@g, #Create, 4, 4, 588, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiTextArea    (@g, #Create, 4, 24, 588, 112, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitAssembly(), 0, 0, $textArea, grid)
	XuiPushButton  (@g, #Create, 4, 136, 147, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitAssembly(), -1, -1, $button0, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" next ")
	XuiPushButton  (@g, #Create, 151, 136, 147, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitAssembly(), -1, -1, $button1, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" current ")
	XuiPushButton  (@g, #Create, 298, 136, 147, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitAssembly(), -1, -1, $button2, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" back ")
	XuiPushButton  (@g, #Create, 445, 136, 147, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitAssembly(), -1, -1, $button3, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	XuiSendMessage ( grid, #GetFontNumber, @font, 0, 0, 0, 0, 0)
	XgrGetFontMetrics (font, @maxCharWidth, 0, 0, 0, 0, 0)
	XuiSendMessage ( grid, #SetTabWidth, (maxCharWidth << 3), 0, 0, 0, $textArea, 0)
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Assembly")
END SUB
'
'
' *****  GetSmallestSize  *****
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	bw = border
'
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, 0, @labelHeight, $label, 16)
	XuiSendToKid (grid, #GetSmallestSize, 20, 4, @areaWidth, @areaHeight, $textArea, 16)
'
	buttonWidth = 12
	buttonHeight = 12
	FOR i = $button0 TO $button3
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 12)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
	width = buttonWidth << 2
	width = MAX (width, areaWidth)
	width = MAX (width, lineWidth)
	v2 = width + bw + bw
	v3 = labelHeight + areaHeight + buttonHeight + bw + bw
	minW = v2
	minH = v3
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize				' returns bw and heights
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	h = minH
'
	IF (v3 > (h + 4)) THEN
		buttonHeight = buttonHeight + 4	: h = h + 4
		IF (v3 > (h + 4)) THEN
			labelHeight = labelHeight + 4
		END IF
	END IF
'
'	Resize kids
'
	x = bw
	y = bw
	w = v2 - bw - bw
	h = labelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $label, 0)
'
	y = y + h
	h = v3 - labelHeight - buttonHeight - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w, h, $textArea, 0)
'
	y = y + h
	h = buttonHeight
	w1 = w >> 2
	w2 = v2 - (w1 + w1 + w1) - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w2, h, $button0, 0) : x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button1, 0) : x = x + w1
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button2, 0) : x = x + w1
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button3, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#GotKeyboardFocus]		= &XuiGotKeyboardFocus()
	func[#LostKeyboardFocus]	= &XuiLostKeyboardFocus()
	func[#Resize]							= 0
	func[#SetKeyboardFocus]		= &XuiSetKeyboardFocus()
	func[#TextEvent]					= &XuiTextModifyNot()
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitAssembly() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "XitAssembly() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@XitAssembly, @"XitAssembly", &XitAssembly(), @func[], @sub[])
'
	designX = 0
	designY = 0
	designWidth = 596
	designHeight = 160
'
	gridType = XitAssembly
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Respond OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $textArea)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' #############################
' #####  XitComposite ()  #####
' #############################
'
FUNCTION  XitComposite (grid, message, v0, v1, v2, v3, r0, r1)
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR	 sub[]
	STATIC  upperMessage
	STATIC  XitComposite
'
	$functionLabel	=  1
	$symbolLabel		=  2
	$columnLabel		=  3
	$list						=  4
	$higherButton		=  5
	$lowerButton		=  6
	$viewLabel			=  7
	$viewText				=  8
	$button0				=  9
	$button1				= 10
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitComposite) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh in window : r0 = window
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, XitComposite, @v0, @v1, @v2, @v3, r0, r1, &XitComposite())
	XuiSendMessage ( grid, #SetGridName, 0, 0, 0, 0, 0, @"XitComposite")
	XuiLabel       (@g, #Create, 4, 4, 584, 20, r0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"FunctionLabel")
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyCenter, -1, -1, 0, 0)
	XuiLabel       (@g, #Create, 4, 24, 584, 20, r0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"SymbolLabel")
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyCenter, -1, -1, 0, 0)
	XuiLabel       (@g, #Create, 4, 44, 584, 20, r0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"ColumnLabel")
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyCenter, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"type       symbol                location   hex               value ")
	XuiList        (@g, #Create, 4, 64, 584, 72, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitComposite(), -1, -1, $list, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"ElementList")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 1, @"List")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 2, @"ScrollH")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 3, @"ScrollV")
	XuiPushButton  (@g, #Create, 4, 136, 292, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitComposite(), -1, -1, $higherButton, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"HigherButton")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" <<<  next higher composite <<< ")
	XuiPushButton  (@g, #Create, 296, 136, 292, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitComposite(), -1, -1, $lowerButton, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"LowerButton")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" >>>  next lower composite >>> ")
	XuiLabel       (@g, #Create, 4, 156, 584, 20, r0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"ViewLabel")
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyCenter, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" view element:  .a.b.c ")
	XuiTextLine    (@g, #Create, 4, 176, 584, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitComposite(), -1, -1, $viewText, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"ViewText")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 1, @"ViewTextGrid")
	XuiPushButton  (@g, #Create, 4, 196, 292, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitComposite(), -1, -1, $button0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"DetailButton")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" detail ")
	XuiPushButton  (@g, #Create, 296, 196, 292, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitComposite(), -1, -1, $button1, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"CancelButton")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Composite Detail")
END SUB
'
'
' *****  GetSmallestSize  *****
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @bw)
'
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @functionLabelWidth, @functionLabelHeight, $functionLabel, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @symbolLabelWidth, @symbolLabelHeight, $symbolLabel, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @columnLabelWidth, @columnLabelHeight, $columnLabel, 16)
'
	XuiSendToKid (grid, #GetSmallestSize, 20, 4, @listWidth, @listHeight, $list, 16)
'
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @higherWidth, @higherHeight, $higherButton, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @lowerWidth, @lowerHeight, $lowerButton, 16)
	hiloWidth = MAX(higherWidth, lowerWidth) << 1
	hiloHeight = MAX(higherHeight, lowerHeight)
'
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, 0, @viewLabelHeight, $viewLabel, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, 0, @viewTextHeight, $viewText, 16)
'
	buttonWidth = 16
	buttonHeight = 16
	FOR i = $button0 TO $button1
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
	width = buttonWidth + buttonWidth
	IF (width < functionLabelWidth) THEN width = functionLabelWidth
	IF (width < symbolLabelWidth) THEN width = symbolLabelWidth
	IF (width < columnLabelWidth) THEN width = columnLabelWidth
	IF (width < listWidth) THEN width = listWidth
	IF (width < hiloWidth) THEN width = hiloWidth
	v2 = width + bw + bw
	v3 = functionLabelHeight + symbolLabelHeight + columnLabelHeight
	v3 = v3 + listHeight + hiloHeight
	v3 = v3 + viewLabelHeight + viewTextHeight + buttonHeight + bw + bw
	minW = v2
	minH = v3
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	vv2 = v2
	vv3 = v3
	GOSUB GetSmallestSize				' returns bw and heights
	v2 = MAX(vv2, v2)
	v3 = MAX(vv3, v3)
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	h = minH
'
	IF (v3 > (h + 4)) THEN
		buttonHeight = buttonHeight + 4										:	h = h + 4
		IF (v3 > (h + 4)) THEN
			higherHeight = higherHeight + 4									:	h = h + 4
			IF (v3 > (h + 12)) THEN
				functionLabelHeight = functionLabelHeight + 4	:	h = h + 12
				symbolLabelHeight = symbolLabelHeight + 4
				columnLabelHeight = columnLabelHeight + 4
				IF (v3 > (h + 8)) THEN
					viewLabelHeight = viewLabelHeight + 4
					viewTextHeight = viewTextHeight + 4
				END IF
			END IF
		END IF
	END IF
'
	x = bw
	y = bw
	w = v2 - bw - bw
	h = functionLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $functionLabel, 0)
'
	y = y + h
	h = symbolLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $symbolLabel, 0)
'
	y = y + h
	h = columnLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $columnLabel, 0)
'
	y = y + h
	h = v3 - functionLabelHeight - symbolLabelHeight - columnLabelHeight
	h = h - higherHeight - viewLabelHeight - viewTextHeight
	h = h - buttonHeight - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w, h, $list, 0)
'
	y = y + h
	h = higherHeight
	w1 = (v2 - bw - bw) >> 1
	w2 = v2 - w1 - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w2, h, $higherButton, 0) : x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $lowerButton, 0)
'
	x = bw
	y = y + h
	w = v2 - bw - bw
	h = viewLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $viewLabel, 0)
	y = y + h
	h = viewTextHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $viewText, 0)
'
	y = y + h
	h = buttonHeight
	w1 = w >> 1
	w2 = v2 - w1 - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w2, h, $button0, 0) : x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button1, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#GotKeyboardFocus]		= &XuiGotKeyboardFocus()
	func[#LostKeyboardFocus]	= &XuiLostKeyboardFocus()
	func[#Resize]							= 0
	func[#SetKeyboardFocus]		= &XuiSetKeyboardFocus()
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitComposite() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "XitComposite() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@XitComposite, @"XitComposite", &XitComposite(), @func[], @sub[])
'
	designX = 4
	designY = 23
	designWidth = 592
	designHeight = 220
'
	gridType = XitComposite
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Respond OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $viewText)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
'	###############################
'	#####  Xit2LineDialog ()  #####
'	###############################
'
FUNCTION  Xit2LineDialog (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR  sub[]
	STATIC  upperMessage
	STATIC  Xit2LineDialog

	$label0		= 1
	$text0		= 2	: $focusKid = 2
	$label1		= 3
	$text1		= 4
	$button0	= 5
	$button1	= 6
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, Xit2LineDialog) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
'	*****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
  IF (v0 <= 0) THEN v0 = 0
  IF (v1 <= 0) THEN v1 = 0
  IF (v2 <= 0) THEN v2 = designWidth
  IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, Xit2LineDialog, v0, v1, v2, v3, r0, r1, &Xit2LineDialog())
	XuiLabel       (@g, #Create, 4, 24, 372, 20, r0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"Label0")
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, 4, 0, 0, 0)
	XuiTextLine    (@g, #Create, 4, 44, 372, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Xit2LineDialog(), -1, -1, $text0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"Text0")
	XuiLabel       (@g, #Create, 4, 64, 372, 20, r0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"Label1")
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, 4, 0, 0, 0)
	XuiTextLine    (@g, #Create, 4, 84, 372, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Xit2LineDialog(), -1, -1, $text1, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"Text1")
	XuiPushButton  (@g, #Create, 4, 144, 124, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Xit2LineDialog(), -1, -1, $button0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"Button0")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" ok ")
	XuiPushButton  (@g, #Create, 128, 144, 124, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &Xit2LineDialog(), -1, -1, $button1, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"Button1")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	GOSUB Resize
END SUB
'
'
'	*****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
  IF (v0  = 0) THEN v0 = designX
  IF (v1  = 0) THEN v1 = designY
  IF (v2 <= 0) THEN v2 = designWidth
  IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Xit2LineDialog")
END SUB
'
'
'	*****  GetSmallestSize  *****  Return v23 = smallest wh
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	bw = border
'
	labelWidth = 16
	labelHeight = 16
	FOR i = $label0 TO $label1 STEP 2
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > labelWidth) THEN labelWidth = width
		IF (height > labelHeight) THEN labelHeight = height
	NEXT i
'
	textHeight = 0
	FOR i = $text0 TO $text1 STEP 2
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, 0, @height, i, 16)
		IF (height > textHeight) THEN textHeight = height
	NEXT i
'
	buttonWidth = 16
	buttonHeight = 16
	FOR i = $button0 TO $button1
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 8)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
	buttonWidth = buttonWidth + buttonWidth + buttonWidth
'
	width = MAX(buttonWidth, labelWidth) + bw + bw
	height = labelHeight + textHeight
	height = height + height + buttonHeight + bw + bw
	v2 = width
	v3 = height
	minW = v2
	minH = v3
END SUB
'
'
'	*****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, v0, v1, v2, v3)
	h = labelHeight + textHeight
	h = h + h + buttonHeight + bw + bw
	IF (v3 > (h + 4)) THEN
		buttonHeight = buttonHeight + 4	:	h = h + 4
		IF (v3 > (h + 8)) THEN
			textHeight = textHeight + 4
		END IF
	END IF
'
'	Resize kids
'
	width = v2 - bw - bw
	x = bw
	y = bw
	w = width
	ht = textHeight
	h = ht + ht + buttonHeight + bw + bw
	h1 = (v3 - h) >> 1
	h2 = v3 - h - h1
	XuiSendToKid (grid, #Resize, x, y, w, h2, $label0, 0)	: y = y + h2
	XuiSendToKid (grid, #Resize, x, y, w, ht, $text0, 0)	: y = y + ht
	XuiSendToKid (grid, #Resize, x, y, w, h1, $label1, 0)	: y = y + h1
	XuiSendToKid (grid, #Resize, x, y, w, ht, $text1, 0)	: y = y + ht
'
	w1 = w >> 1
	w2 = w - w1
	h = buttonHeight
	XuiSendToKid (grid, #Resize, x, y, w2, h, $button0, 0):	x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button1, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#Resize]							= 0
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "Xit2LineDialog() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "Xit2LineDialog() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@Xit2LineDialog, "Xit2LineDialog", &Xit2LineDialog(), @func[], @sub[])
'
	designX = 0
	designY = 0
	designWidth = 380
	designHeight = 168
'
	gridType = Xit2LineDialog
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus)
	XuiSetGridTypeValue (gridType, @"focusKid",      $focusKid)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ################################
' #####  XitErrorCompile ()  #####
' ################################
'
FUNCTION  XitErrorCompile (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR	 sub[]
	STATIC  upperMessage
	STATIC  XitErrorCompile
'
	$label0		= 1
	$label1		= 2
	$button0	= 3
	$button1	= 4
	$button2	= 5
	$button3	= 6
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitErrorCompile) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, XitErrorCompile, @v0, @v1, @v2, @v3, r0, r1, &XitErrorCompile())
	XuiLabel       (@g, #Create, 4, 4, 368, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiLabel       (@g, #Create, 4, 24, 368, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiPushButton  (@g, #Create, 4, 44, 92, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitErrorCompile(), -1, -1, $button0, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" next ")
	XuiPushButton  (@g, #Create, 96, 44, 92, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitErrorCompile(), -1, -1, $button1, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" current ")
	XuiPushButton  (@g, #Create, 188, 44, 92, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitErrorCompile(), -1, -1, $button2, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" previous ")
	XuiPushButton  (@g, #Create, 280, 44, 92, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitErrorCompile(), -1, -1, $button3, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Compilation Errors")
END SUB
'
'
' *****  GetSmallestSize  *****
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	bw = border
'
	labelWidth = 16
	labelHeight = 16
	FOR i = $label0 TO $label1
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > labelWidth) THEN labelWidth = width
		IF (height > labelHeight) THEN labelHeight = height
	NEXT i
'
	buttonWidth = 16
	buttonHeight = 16
	FOR i = $button0 TO $button3
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
	width = buttonWidth << 2
	width = MAX (width, labelWidth)
	v2 = width + bw + bw
	v3 = labelHeight + labelHeight + buttonHeight + bw + bw
	minW = v2
	minH = v3
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize				' returns bw and heights
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	h = labelHeight + labelHeight + buttonHeight + bw + bw
	IF (v3 > (h + 4)) THEN buttonHeight = buttonHeight + 4
'
'	Resize kids
'
	x = bw
	y = bw
	w = v2 - bw - bw
	h = v3 - buttonHeight - bw - bw
	h1 = h >> 1
	h2 = h - h1
	XuiSendToKid (grid, #Resize, x, y, w, h1, $label0, 0) : y = y + h1
	XuiSendToKid (grid, #Resize, x, y, w, h2, $label1, 0)
'
	y = y + h2
	h = buttonHeight
	w1 = w >> 2
	w2 = v2 - (w1 + w1 + w1) - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w2, h, $button0, 0) : x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button1, 0) : x = x + w1
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button2, 0) : x = x + w1
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button3, 0) : x = x + w1
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#Resize]							= 0
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitErrorCompile() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "XitErrorCompile() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@XitErrorCompile, @"XitErrorCompile", &XitErrorCompile(), @func[], @sub[])
'
	designX = 0
	designY = 0
	designWidth = 376
	designHeight = 68
'
	gridType = XitErrorCompile
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Respond OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $button0)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ################################
' #####  XitErrorRuntime ()  #####
' ################################
'
FUNCTION  XitErrorRuntime (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR	 sub[]
	STATIC  upperMessage
	STATIC  XitErrorRuntime
'
	$label0	= 1
	$label1	= 2
	$button	= 3
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitErrorRuntime) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, XitErrorRuntime, @v0, @v1, @v2, @v3, r0, r1, &XitErrorRuntime())
	XuiLabel       (@g, #Create, 4, 4, 368, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiLabel       (@g, #Create, 4, 24, 368, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiPushButton  (@g, #Create, 4, 44, 368, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitErrorRuntime(), -1, -1, $button, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Runtime Error")
END SUB
'
'
' *****  GetSmallestSize  *****
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	bw = border
'
	labelWidth = 16
	labelHeight = 16
	FOR i = $label0 TO $label1
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > labelWidth) THEN labelWidth = width
		IF (height > labelHeight) THEN labelHeight = height
	NEXT i
'
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, $button, 16)
	buttonWidth = width
	buttonHeight = height
	width = buttonWidth
	width = MAX (width, labelWidth)
	v2 = width + bw + bw
	v3 = labelHeight + labelHeight + buttonHeight + bw + bw
	minW = v2
	minH = v3
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize				' returns bw and heights
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	h = labelHeight + labelHeight + buttonHeight + bw + bw
	IF (v3 > (h + 4)) THEN buttonHeight = buttonHeight + 4
'
'	Resize kids
'
	x = bw
	y = bw
	w = v2 - bw - bw
	h = v3 - buttonHeight - bw - bw
	h1 = h >> 1
	h2 = h - h1
	XuiSendToKid (grid, #Resize, x, y, w, h1, $label0, 0) : y = y + h1
	XuiSendToKid (grid, #Resize, x, y, w, h2, $label1, 0)
'
	y = y + h2
	h = buttonHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $button, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#Resize]							= 0
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitErrorRuntime() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "XitErrorRuntime() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@XitErrorRuntime, @"XitErrorRuntime", &XitErrorRuntime(), @func[], @sub[])
'
	designX = 0
	designY = 0
	designWidth = 376
	designHeight = 68
'
	gridType = XitErrorRuntime
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $button)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
'	########################
'	#####  XitFind ()  #####
'	########################
'
FUNCTION  XitFind (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR  sub[]
	STATIC  upperMessage
	STATIC  XitFind
'
	$caseToggle			= 1
	$localToggle		= 2
	$reverseToggle	= 3
	$findLabel			= 4
	$findText				= 5  : $focusKid = 5
	$replaceLabel		= 6
	$replaceText		= 7
	$repsLabel			= 8
	$repsText				= 9
	$findButton			= 10
	$replaceButton	= 11
	$cancelButton		= 12
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitFind) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
'	*****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid		(@grid, XitFind, v0, v1, v2, v3, r0, r1, &XitFind())
	XuiToggleButton	(@g, #Create, 4, 4, 124, 20, r0, grid)
	XuiSendMessage	( g, #SetCallback, grid, &XitFind(), -1, -1, $caseToggle, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"caseToggle")
	XuiSendMessage	( g, #SetTextString, 0, 0, 0, 0, 0, @" case sensitive ")
	XuiToggleButton	(@g, #Create, 128, 4, 124, 20, r0, grid)
	XuiSendMessage	( g, #SetCallback, grid, &XitFind(), -1, -1, $localToggle, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"localToggle")
	XuiSendMessage	( g, #SetTextString, 0, 0, 0, 0, 0, @" local ")
	XuiToggleButton	(@g, #Create, 252, 4, 124, 20, r0, grid)
	XuiSendMessage	( g, #SetCallback, grid, &XitFind(), -1, -1, $reverseToggle, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"reverseToggle")
	XuiSendMessage	( g, #SetTextString, 0, 0, 0, 0, 0, @" reverse ")
	XuiLabel				(@g, #Create, 4, 24, 372, 20, r0, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"findLabel")
	XuiSendMessage	( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, 4, 0, 0, 0)
	XuiSendMessage	( g, #SetTextString, 0, 0, 0, 0, 0, @"find string")
	XuiTextLine			(@g, #Create, 4, 44, 372, 20, r0, grid)
	XuiSendMessage	( g, #SetCallback, grid, &XitFind(), -1, -1, $findText, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"findText")
	XuiLabel				(@g, #Create, 4, 64, 372, 20, r0, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"replaceLabel")
	XuiSendMessage	( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, 4, 0, 0, 0)
	XuiSendMessage	( g, #SetTextString, 0, 0, 0, 0, 0, @"replace string")
	XuiTextLine			(@g, #Create, 4, 84, 372, 20, r0, grid)
	XuiSendMessage	( g, #SetCallback, grid, &XitFind(), -1, -1, $replaceText, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"replaceText")
	XuiLabel				(@g, #Create, 4, 104, 372, 20, r0, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"repsLabel")
	XuiSendMessage	( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, 4, 0, 0, 0)
	XuiSendMessage	( g, #SetTextString, 0, 0, 0, 0, 0, @"repetitions  [* = all]")
	XuiTextLine			(@g, #Create, 4, 124, 372, 20, r0, grid)
	XuiSendMessage	( g, #SetCallback, grid, &XitFind(), -1, -1, $repsText, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"repsText")
	XuiSendMessage	( g, #SetTextString, 0, 0, 0, 0, 0, @"1")
	XuiPushButton		(@g, #Create, 4, 144, 124, 20, r0, grid)
	XuiSendMessage	( g, #SetCallback, grid, &XitFind(), -1, -1, $findButton, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"findButton")
	XuiSendMessage	( g, #SetTextString, 0, 0, 0, 0, 0, @" find ")
	XuiPushButton		(@g, #Create, 128, 144, 124, 20, r0, grid)
	XuiSendMessage	( g, #SetCallback, grid, &XitFind(), -1, -1, $replaceButton, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"replaceButton")
	XuiSendMessage	( g, #SetTextString, 0, 0, 0, 0, 0, @" replace ")
	XuiPushButton		(@g, #Create, 252, 144, 124, 20, r0, grid)
	XuiSendMessage	( g, #SetCallback, grid, &XitFind(), -1, -1, $cancelButton, grid)
	XuiSendMessage	( g, #SetGridName, 0, 0, 0, 0, 0, @"cancelButton")
	XuiSendMessage	( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	GOSUB Resize
END SUB
'
'
'	*****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Find")
END SUB
'
'
'	*****  GetSmallestSize  *****
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	bw = border
'
	toggleWidth = 16
	toggleHeight = 16
	FOR i = $caseToggle TO $reverseToggle
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > toggleWidth) THEN toggleWidth = width
		IF (height > toggleHeight) THEN toggleHeight = height
	NEXT i
	toggleWidth = toggleWidth + toggleWidth + toggleWidth
'
	labelWidth = 0
	labelHeight = 0
	FOR i = $findLabel TO $repsLabel STEP 2
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > labelWidth) THEN labelWidth = width
		IF (height > labelHeight) THEN labelHeight = height
	NEXT i
'
	textHeight = 16
	FOR i = $findText TO $repsText STEP 2
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, 0, @height, i, 16)
		IF (height > textHeight) THEN textHeight = height
	NEXT i
'
	buttonWidth = 16
	buttonHeight = 16
	FOR i = $findButton TO $cancelButton
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
	buttonWidth = buttonWidth + buttonWidth + buttonWidth
'
	width = MAX(toggleWidth, labelWidth)
	width = MAX(width, buttonWidth) + bw + bw
	height = labelHeight + textHeight
	height = height + height + height
	height = height + toggleHeight + buttonHeight + bw + bw
	v2 = width
	v3 = height
	minW = v2
	minH = v3
END SUB
'
'
'	*****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, v0, v1, v2, v3)
	h = labelHeight + textHeight
	h = h + h + h + toggleHeight + buttonHeight + bw + bw
	IF (v3 > (h + 4)) THEN
		buttonHeight = buttonHeight + 4		:	h = h + 4
		IF (v3 > (h + 4)) THEN
			toggleHeight = toggleHeight + 4	:	h = h + 4
			IF (v3 > (h + 12)) THEN
				textHeight = textHeight + 4
			END IF
		END IF
	END IF
'
'	Resize kids
'
	width = v2 - bw - bw
	x = bw
	y = bw
	w1 = width / 3
	w2 = width - w1 - w1
	h = toggleHeight
	XuiSendToKid (grid, #Resize, x, y, w1, h, $caseToggle, 0):			x = x + w1
	XuiSendToKid (grid, #Resize, x, y, w2, h, $localToggle, 0):		x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $reverseToggle, 0)
'
	x = bw
	y = y + h
	w = width
	ht = textHeight
	h = ht + ht + ht + toggleHeight + buttonHeight + bw + bw
	h1 = (v3 - h) / 3
	h2 = v3 - h - h1 - h1
	XuiSendToKid (grid, #Resize, x, y, w, h2, $findLabel, 0):			y = y + h2
	XuiSendToKid (grid, #Resize, x, y, w, ht, $findText, 0):				y = y + ht
	XuiSendToKid (grid, #Resize, x, y, w, h1, $replaceLabel, 0):		y = y + h1
	XuiSendToKid (grid, #Resize, x, y, w, ht, $replaceText, 0):		y = y + ht
	XuiSendToKid (grid, #Resize, x, y, w, h1, $repsLabel, 0):			y = y + h1
	XuiSendToKid (grid, #Resize, x, y, w, ht, $repsText, 0):				y = y + ht
'
	h = buttonHeight
	XuiSendToKid (grid, #Resize, x, y, w1, h, $findButton, 0):			x = x + w1
	XuiSendToKid (grid, #Resize, x, y, w2, h, $replaceButton, 0):	x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $cancelButton, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#Resize]							= 0
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitFind() : Initialize : error ::: undefined message Initialize: Error::: Undefined Message"
	IF sub[0] THEN PRINT "XitFind() : Initialize : error ::: undefined message Initialize: Error::: Undefined Message"
	XuiRegisterGridType (@XitFind, "XitFind", &XitFind(), @func[], @sub[])
'
	designX = 0
	designY = 0
	designWidth = 380
	designHeight = 168
'
	gridType = XitFind
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus)
	XuiSetGridTypeValue (gridType, @"focusKid",      $focusKid)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ##########################
' #####  XitFrames ()  #####
' ##########################
'
FUNCTION  XitFrames (grid, message, v0, v1, v2, v3, r0, (r1, r1$, r1$[]))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR	 sub[]
	STATIC  upperMessage
	STATIC  XitFrames
'
	$label				= 1
	$list					= 2
	$button0			= 3
	$button1			= 4
	$button2			= 5
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitFrames) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh in window : r0 = window
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, XitFrames, v0, v1, v2, v3, r0, r1, &XitFrames())
	XuiLabel       (@g, #Create, 0, 0, 1, 1, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"   #      line  function        ")
	XuiList        (@g, #Create, 0, 0, 1, 1, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitFrames(), -1, -1, $list, grid)
	XuiPushButton  (@g, #Create, 0, 0, 1, 1, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitFrames(), -1, -1, $button0, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" view ")
	XuiPushButton  (@g, #Create, 0, 0, 1, 1, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitFrames(), -1, -1, $button1, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" detail ")
	XuiPushButton  (@g, #Create, 0, 0, 1, 1, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitFrames(), -1, -1, $button2, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Call Frames")
END SUB
'
'
' *****  GetSmallestSize  *****
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @labelWidth, @labelHeight, $label, 16)
	XuiSendToKid (grid, #GetMaxMinSize, 20, 1, @listWidth, @listHeight, $list, 0)
	bw = border
'
	buttonWidth = 16
	buttonHeight = 16
	FOR i = $button0 TO $button2
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
'
	width = MAX(labelWidth, buttonWidth)
	v2 = MAX(width, listWidth) + bw + bw
	v3 = labelHeight + listHeight + buttonHeight + bw + bw
	minW = v2
	minH = v3
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize				' returns bw and heights
	v2 = MAX (v2Entry, v2)
	v3 = MAX (v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	h = minH
'
	IF (v3 > (h + 4)) THEN
		buttonHeight = buttonHeight + 4	: h = h + 4
		IF (v3 > (h + 4)) THEN
			labelHeight = labelHeight + 4
		END IF
	END IF
'
'	Resize kids
'
	x = bw
	y = bw
	w = v2 - bw - bw
	h = labelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $label, 0)
'
	y = y + h
	h = v3 - labelHeight - buttonHeight - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w, h, $list, 0)
'
	y = y + h
	w1 = w / 3
	w2 = w - w1 - w1
	h = buttonHeight
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button0, 0) : x = x + w1
	XuiSendToKid (grid, #Resize, x, y, w2, h, $button1, 0) : x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button2, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#GotKeyboardFocus]		= &XuiGotKeyboardFocus()
	func[#LostKeyboardFocus]	= &XuiLostKeyboardFocus()
	func[#Resize]							= 0
	func[#SetKeyboardFocus]		= &XuiSetKeyboardFocus()
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitFrames() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "XitFrames() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@XitFrames, @"XitFrames", &XitFrames(), @func[], @sub[])
'
	designX = 0
	designY = 0
	designWidth = 160
	designHeight = 256
'
	gridType = XitFrames
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    64)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Respond OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $button0)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ##########################
' #####  XitMemory ()  #####
' ##########################
'
FUNCTION  XitMemory (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR	 sub[]
	STATIC  upperMessage
	STATIC  XitMemory
'
	$textArea	= 1
	$textLine	= 2
	$button0	= 3
	$button1	= 4
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, @XitMemory) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, XitMemory, @v0, @v1, @v2, @v3, r0, r1, &XitMemory())
	XuiTextArea    (@g, #Create, 4, 4, 668, 220, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitMemory(), -1, -1, $textArea, grid)
	XuiTextLine    (@g, #Create, 4, 224, 668, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitMemory(), -1, -1, $textLine, grid)
	XuiPushButton  (@g, #Create, 4, 244, 334, 20, r0, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" execute ")
	XuiSendMessage ( g, #SetCallback, grid, &XitMemory(), -1, -1, $button0, grid)
	XuiPushButton  (@g, #Create, 338, 244, 334, 20, r0, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	XuiSendMessage ( g, #SetCallback, grid, &XitMemory(), -1, -1, $button1, grid)
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Memory")
END SUB
'
'
' *****  GetSmallestSize  *****  Return v23 = smallest wh
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	bw = border
'
	XuiSendToKid (grid, #GetSmallestSize, 20, 4, @areaWidth, @areaHeight, $textArea, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, 0, @lineHeight, $textLine, 16)
'
	buttonWidth = 16
	buttonHeight = 16
	FOR i = $button0 TO $button1
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
	width = buttonWidth + buttonWidth
	width = MAX (width, areaWidth)
	width = MAX (width, lineWidth)
	v2 = width + bw + bw
	v3 = areaHeight + lineHeight + buttonHeight + bw + bw
	minW = v2
	minH = v3
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize				' returns bw and heights
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	h = minH
'
	IF (v3 > (h + 4)) THEN
		buttonHeight = buttonHeight + 4:		h = h + 4
		IF (v3 > (h + 4)) THEN
			lineHeight = lineHeight + 4
		END IF
	END IF
'
'	Resize kids
'
	x = bw
	y = bw
	w = v2 - bw - bw
	h = v3 - lineHeight - buttonHeight - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w, h, $textArea, 0)
'
	y = y + h
	h = lineHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $textLine, 0)
'
	y = y + h
	h = buttonHeight
	w = w >> 1
	XuiSendToKid (grid, #Resize, x, y, w, h, $button0, 0) : x = x + w
	XuiSendToKid (grid, #Resize, x, y, w, h, $button1, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#GotKeyboardFocus]		= &XuiGotKeyboardFocus()
	func[#LostKeyboardFocus]	= &XuiLostKeyboardFocus()
	func[#Resize]							= 0
	func[#SetKeyboardFocus]		= &XuiSetKeyboardFocus()
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitMemory() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "XitMemory() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@XitMemory, @"XitMemory", &XitMemory(), @func[], @sub[])
'
	designX = 0
	designY = 0
	designWidth = 378
	designHeight = 256
'
	gridType = XitMemory
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Respond OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $textLine)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ##############################
' #####  XitOptionMisc ()  #####
' ##############################
'
FUNCTION  XitOptionMisc (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC	SUBADDR	 sub[]
	STATIC	XitOptionMisc
	STATIC	func[]
'
	$XitOptionMisc          =   0  ' kid   0 grid type = XitOptionMisc
	$CheckBounds            =   1  ' kid   1 grid type = XuiCheckBox
	$CheckSaveNewline       =   2  ' kid   2 grid type = XuiCheckBox
	$CheckConsoleDarkColor  =   3  ' kid   3 grid type = XuiCheckBox
	$CheckPasteNewline      =   4  ' kid   4 grid type = XuiCheckBox
	$CheckConsoleLargeFont  =   5  ' kid   5 grid type = XuiCheckBox
	$CheckProgramLargeFont  =   6  ' kid   6 grid type = XuiCheckBox
	$CheckConsoleLargeBars  =   7  ' kid   7 grid type = XuiCheckBox
	$CheckProgramLargeBars  =   8  ' kid   8 grid type = XuiCheckBox
	$ButtonEnter            =   9  ' kid   9 grid type = XuiPushButton
	$UpperKid               =   9  ' kid maximum
'
'	XgrMessageNumberToName (r1, @mess$)
'	XgrMessageNumberToName (message, @message$)
'	PRINT "XitOptionMisc() : "; grid;; message$;; v0; v1; v2; v3; r0; r1;; mess$
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitOptionMisc) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, XitOptionMisc, @v0, @v1, @v2, @v3, r0, r1, &XitOptionMisc())
	XuiSendMessage ( grid, #SetGridName, 0, 0, 0, 0, 0, @"XitOptionMisc")
	XuiCheckBox    (@g, #Create, 4, 4, 192, 28, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitOptionMisc(), -1, -1, $CheckBounds, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"CheckBounds")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" check bounds ")
	XuiCheckBox    (@g, #Create, 196, 4, 192, 28, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitOptionMisc(), -1, -1, $CheckSaveNewline, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"CheckSaveNewline")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" save with \\r\\n")
	XuiCheckBox    (@g, #Create, 4, 32, 192, 28, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitOptionMisc(), -1, -1, $CheckConsoleDarkColor, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"CheckConsoleDarkColor")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" console dark color")
	XuiCheckBox    (@g, #Create, 196, 32, 192, 28, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitOptionMisc(), -1, -1, $CheckPasteNewline, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"CheckPasteNewline")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" paste with \\r\\n")
	XuiCheckBox    (@g, #Create, 4, 60, 192, 28, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitOptionMisc(), -1, -1, $CheckConsoleLargeFont, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"CheckConsoleLargeFont")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" console large font")
	XuiCheckBox    (@g, #Create, 196, 60, 192, 28, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitOptionMisc(), -1, -1, $CheckProgramLargeFont, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"CheckProgramLargeFont")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" program large font")
	XuiCheckBox    (@g, #Create, 4, 88, 192, 28, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitOptionMisc(), -1, -1, $CheckConsoleLargeBars, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"CheckConsoleLargeBars")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" console large bars")
	XuiCheckBox    (@g, #Create, 196, 88, 192, 28, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitOptionMisc(), -1, -1, $CheckProgramLargeBars, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"CheckProgramLargeBars")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" program large bars")
	XuiPushButton  (@g, #Create, 4, 116, 384, 28, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitOptionMisc(), -1, -1, $ButtonEnter, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"ButtonEnter")
	XuiSendMessage ( g, #SetStyle, 0, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetColor, 17, $$Black, $$Black, $$White, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"enter")
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @" Miscellaneous Options ")
END SUB
'
'
' *****  GetSmallestSize  *****  Return v23 = smallest wh  (set variables for Resize)
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	bw = border
'
	buttonWidth = 16
	buttonHeight = 16
	FOR i = $CheckBounds TO $ButtonEnter
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		buttonWidth = MAX (width, buttonWidth)
		buttonHeight = MAX (height, buttonHeight)
	NEXT i
	v2 = buttonWidth + buttonWidth + bw + bw + 4
	v3 = (buttonHeight << 2) + buttonHeight + bw + bw + 4
	minW = v2
	minH = v3
END SUB
'
'
' *****  KeyDown  *****
'
SUB KeyDown
	SELECT CASE v2{$$VirtualKey}
		CASE $$KeyEnter
					XuiCallback (grid, #Selection, 0, 0, 0, 0, 0, grid)
		CASE $$KeyEscape
					XuiCallback (grid, #Selection, -1, 0, 0, 0, 0, grid)
	END SELECT
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	buttonWidth = v2 >> 1
	buttonHeight = (v3 - bw - bw) \ 5
'
	IF (v3 >= ((buttonHeight << 2) + buttonHeight + bw + bw + 20)) THEN
		buttonHeight = buttonHeight + 4
	END IF
'
'	Resize kids
'
	xl = bw
	xr = bw + buttonWidth
	y1 = bw
	y2 = y1 + buttonHeight
	y3 = y2 + buttonHeight
	y4 = y3 + buttonHeight
	y5 = y4 + buttonHeight
	wl = buttonWidth
	wr = v2 - wl - bw - bw
	wt = v2 - bw - bw
	h1 = buttonHeight
	h2 = buttonHeight
	h3 = buttonHeight
	h4 = buttonHeight
	h5 = v3 - h1 - h2 - h3 - h4 - bw - bw
'
	XuiSendToKid (grid, #Resize, xl, y1, wl, h1, $CheckBounds, 0)
	XuiSendToKid (grid, #Resize, xr, y1, wr, h1, $CheckSaveNewline, 0)
	XuiSendToKid (grid, #Resize, xl, y2, wl, h2, $CheckConsoleDarkColor, 0)
	XuiSendToKid (grid, #Resize, xr, y2, wr, h2, $CheckPasteNewline, 0)
	XuiSendToKid (grid, #Resize, xl, y3, wl, h3, $CheckConsoleLargeFont, 0)
	XuiSendToKid (grid, #Resize, xr, y3, wr, h3, $CheckProgramLargeFont, 0)
	XuiSendToKid (grid, #Resize, xl, y4, wl, h4, $CheckConsoleLargeBars, 0)
	XuiSendToKid (grid, #Resize, xr, y4, wr, h4, $CheckProgramLargeBars, 0)
	XuiSendToKid (grid, #Resize, xl, y5, wt, h5, $ButtonEnter, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#Resize]							= 0
'
	DIM sub[#LastMessage]
'	sub[#Callback]						= SUBADDRESS (Callback)
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#KeyDown]							= SUBADDRESS (KeyDown)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitOptionMisc() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "XitOptionMisc() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@XitOptionMisc, @"XitOptionMisc", &XitOptionMisc(), @func[], @sub[])
'
	designX = 4
	designY = 23
	designWidth = 392
	designHeight = 148
'
	gridType = XitOptionMisc
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Respond OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $ButtonEnter)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' #############################
' #####  XitRegisters ()  #####
' #############################
'
FUNCTION  XitRegisters (grid, message, v0, v1, v2, v3, r0, (r1, r1$, r1$[]))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR	 sub[]
	STATIC  upperMessage
	STATIC  XitRegisters
'
	$label		= 1
	$textArea	= 2
	$textLine	= 3
	$button0	= 4
	$button1	= 5
	$button2	= 6
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitRegisters) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, XitRegisters, @v0, @v1, @v2, @v3, r0, r1, &XitRegisters())
	XuiLabel       (@g, #Create, 4, 4, 508, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiTextArea    (@g, #Create, 4, 24, 508, 72, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitRegisters(), -1, -1, $textArea, grid)
	XuiTextLine    (@g, #Create, 4, 96, 508, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitRegisters(), -1, -1, $textLine, grid)
	XuiPushButton  (@g, #Create, 4, 116, 169, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitRegisters(), -1, -1, $button0, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" set ")
	XuiPushButton  (@g, #Create, 174, 116, 170, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitRegisters(), -1, -1, $button1, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" reset ")
	XuiPushButton  (@g, #Create, 343, 116, 169, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitRegisters(), -1, -1, $button2, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Registers")
END SUB
'
'
' *****  GetSmallestSize  *****
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @bw)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, 0, @labelHeight, $label, 16)
	XuiSendToKid (grid, #GetSmallestSize, 20, 4, @areaWidth, @areaHeight, $textArea, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, 0, @lineHeight, $textLine, 16)
'
	buttonWidth = 16
	buttonHeight = 16
	FOR i = $button0 TO $button2
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 8)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
	width = buttonWidth + buttonWidth + buttonWidth
	width = MAX (width, areaWidth)
	width = MAX (width, lineWidth)
	v2 = width + bw + bw
	v3 = labelHeight + areaHeight + lineHeight + buttonHeight + bw + bw
	minW = v2
	minH = v3
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize				' returns bw and heights
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	h = minH
'
	IF (v3 > (h + 4)) THEN
		buttonHeight = buttonHeight + 4	:	h = h + 4
		IF (v3 > (h + 4)) THEN
			lineHeight = lineHeight + 4		:	h = h + 4
			IF (v3 > (h + 4)) THEN
				labelHeight = labelHeight + 4
			END IF
		END IF
	END IF
'
'	Resize kids
'
	x = bw
	y = bw
	w = v2 - bw - bw
	h = labelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $label, 0)
'
	y = y + h
	h = v3 - labelHeight - lineHeight - buttonHeight - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w, h, $textArea, 0)
'
	y = y + h
	h = lineHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $textLine, 0)
'
	y = y + h
	h = buttonHeight
	w0 = w / 3
	w1 = w - w0 - w0
	w2 = w0
	XuiSendToKid (grid, #Resize, x, y, w0, h, $button0, 0) : x = x + w0
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button1, 0) : x = x + w1
	XuiSendToKid (grid, #Resize, x, y, w2, h, $button2, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  TextEvent  *****
'
SUB TextEvent
	IF (r0 != $textArea) THEN EXIT SUB
	XgrGetKeystateModify (v2, @modify, @edit)
	IF modify THEN r0 = -1
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#GotKeyboardFocus]		= &XuiGotKeyboardFocus()
	func[#LostKeyboardFocus]	= &XuiLostKeyboardFocus()
	func[#Resize]							= 0
	func[#SetKeyboardFocus]		= &XuiSetKeyboardFocus()
	func[#TextEvent]					= 0
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	sub[#TextEvent]						= SUBADDRESS (TextEvent)
	IF func[0] THEN PRINT "XitRegisters() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "XitRegisters() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@XitRegisters, @"XitRegisters", &XitRegisters(), @func[], @sub[])
'
	designX = 0
	designY = 0
	designWidth = 512
	designHeight = 128
'
	gridType = XitRegisters
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Respond OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $textLine)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ##########################
' #####  XitString ()  #####
' ##########################
'
FUNCTION  XitString (grid, message, v0, v1, v2, v3, r0, r1)
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR	 sub[]
	STATIC  upperMessage
	STATIC  XitString
'
	$functionLabel	= 1
	$symbolLabel		= 2
	$textArea				= 3
	$toggle					= 4
	$button0				= 5
	$button1				= 6
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitString) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh in window : r0 = window
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid   (@grid, XitString, v0, v1, v2, v3, r0, r1, &XitString())
	XuiLabel        (@g, #Create, 4, 4, 532, 20, r0, grid)
	XuiSendMessage  ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiLabel        (@g, #Create, 4, 24, 532, 20, r0, grid)
	XuiSendMessage  ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiTextArea     (@g, #Create, 4, 44, 532, 128, r0, grid)
	XuiSendMessage  ( g, #SetCallback, grid, &XitString(), -1, -1, $textArea, grid)
	XuiToggleButton (@g, #Create, 4, 172, 532, 20, r0, grid)
	XuiSendMessage  ( g, #SetCallback, grid, &XitString(), -1, -1, $toggle, grid)
	XuiSendMessage  ( g, #SetTextString, 0, 0, 0, 0, 0, @" backslash mode ")
	XuiPushButton   (@g, #Create, 4, 192, 266, 20, r0, grid)
	XuiSendMessage  ( g, #SetCallback, grid, &XitString(), -1, -1, $button0, grid)
	XuiSendMessage  ( g, #SetTextString, 0, 0, 0, 0, 0, @" new value ")
	XuiPushButton   (@g, #Create, 270, 192, 266, 20, r0, grid)
	XuiSendMessage  ( g, #SetCallback, grid, &XitString(), -1, -1, $button1, grid)
	XuiSendMessage  ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"String Detail")
END SUB
'
'
' *****  GetSmallestSize  *****
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	bw = border
'
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @functionLabelWidth, @functionLabelHeight, $functionLabel, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @symbolLabelWidth, @symbolLabelHeight, $symbolLabel, 16)
	XuiSendToKid (grid, #GetSmallestSize, 20, 4, @areaWidth, @areaHeight, $textArea, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @toggleWidth, @toggleHeight, $toggle, 16)
'
	buttonWidth = 16
	buttonHeight = 16
	FOR i = $button0 TO $button1
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
	width = buttonWidth << 1
	IF (width < functionLabelWidth) THEN width = functionLabelWidth
	IF (width < symbolLabelWidth) THEN width = symbolLabelWidth
	IF (width < areaWidth) THEN width = areaWidth
	IF (width < toggleWidth) THEN width = toggleWidth
	v2 = width + bw + bw
	v3 = functionLabelHeight + symbolLabelHeight + areaHeight
	v3 = v3 + toggleHeight + buttonHeight + bw + bw
	minW = v2
	minH = v3
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize				' returns bw and heights
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	h = minH
'
	IF (v3 > (h + 4)) THEN
		buttonHeight = buttonHeight + 4		:	h = h + 4
		IF (v3 > (h + 4)) THEN
			toggleHeight = toggleHeight + 4	:	h = h + 4
			IF (v3 > (h + 8)) THEN
				functionLabelHeight = functionLabelHeight + 4
				symbolLabelHeight = symbolLabelHeight + 4
			END IF
		END IF
	END IF
'
'	Resize kids
'
	x = bw
	y = bw
	w = v2 - bw - bw
	h = functionLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $functionLabel, 0)
'
	y = y + h
	h = symbolLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $symbolLabel, 0)
'
	y = y + h
	h = v3 - functionLabelHeight - symbolLabelHeight
	h = h - toggleHeight - buttonHeight - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w, h, $textArea, 0)
'
	y = y + h
	h = toggleHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $toggle, 0)
'
	y = y + h
	h = buttonHeight
	w1 = w >> 1
	w2 = v2 - w1 - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w2, h, $button0, 0) : x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button1, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GotKeyboardFocus]		= &XuiGotKeyboardFocus()
	func[#LostKeyboardFocus]	= &XuiLostKeyboardFocus()
	func[#Resize]							= 0
	func[#SetKeyboardFocus]		= &XuiSetKeyboardFocus()
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitString() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "XitString() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@XitString, @"XitString", &XitString(), @func[], @sub[])
'
	designX = 4
	designY = 23
	designWidth = 512
	designHeight = 128
'
	gridType = XitString
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Respond OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $textArea)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ##############################
' #####  XitTextCursor ()  #####
' ##############################
'
FUNCTION  XitTextCursor (grid, message, v0, v1, v2, v3, r0, r1)
  STATIC  designX,  designY,  designWidth,  designHeight
  STATIC  SUBADDR  sub[]
  STATIC  upperMessage
  STATIC  XitTextCursor
'
  $XitTextCursor          =   0  ' kid   0 grid type = XitTextCursor
  $TextCursorColorLabel   =   1  ' kid   1 grid type = XuiLabel
  $TextCursorColor        =   2  ' kid   2 grid type = XuiColor
  $TextCursorColorSample  =   3  ' kid   3 grid type = XuiTextLine
  $TextCursorColorCancel  =   4  ' kid   4 grid type = XuiPushButton
  $UpperKid               =   4  ' kid maximum
'
  IFZ sub[] THEN GOSUB Initialize
  IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitTextCursor) THEN RETURN
  IF (message <= upperMessage) THEN GOSUB @sub[message]
  RETURN
'
'
' *****  Callback  *****  message = Callback : r1 = original message
'
SUB Callback
  message = r1
  callback = message
  IF (message <= upperMessage) THEN GOSUB @sub[message]
END SUB
'
'
' *****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
  IF (v0 <= 0) THEN v0 = 0
  IF (v1 <= 0) THEN v1 = 0
  IF (v2 <= 0) THEN v2 = designWidth
  IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid (@grid, XitTextCursor, @v0, @v1, @v2, @v3, r0, r1, &XitTextCursor())
	XuiSendMessage ( grid, #SetGridName, 0, 0, 0, 0, 0, @"XitTextCursor")
	XuiLabel       (@g, #Create, 4, 4, 208, 24, r0, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"TextCursorColorLabel")
	XuiSendMessage ( g, #SetColor, 17, $$Black, $$Black, $$White, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" change text cursor color ")
	XuiColor       (@g, #Create, 8, 32, 200, 80, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitTextCursor(), -1, -1, $TextCursorColor, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"TextCursorColor")
	XuiTextLine    (@g, #Create, 4, 116, 208, 24, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitTextCursor(), -1, -1, $TextCursorColorSample, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"TextCursorColorSample")
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"ABCDEFG 0123456789")
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 1, @"Text")
	XuiPushButton  (@g, #Create, 4, 140, 208, 32, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitTextCursor(), -1, -1, $TextCursorColorCancel, grid)
	XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"TextCursorColorCancel")
	XuiSendMessage ( g, #SetColor, 102, $$Black, $$Black, $$White, 0, 0)
	XuiSendMessage ( g, #SetTexture, $$TextureShadow, 0, 0, 0, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
  GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"XitTextCursor")
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
END SUB
'
'
' *****  Selection  *****
'
SUB Selection
	SELECT CASE r0
		CASE 2	: XuiCallback (grid, #Selection, v0, 0, 0, 0, 0, 0)
							XuiSendToKid (grid, #SetKeyboardFocus, 0, 0, 0, 0, 3, 0)
		CASE 3	:
		CASE 4	: XuiCallback (grid, #Selection, -1, 0, 0, 0, 0, 0)
	END SELECT
END SUB
'
'
' *****  TextEvent  *****
'
SUB TextEvent
	IF (v2{$$VirtualKey} = $$KeyEscape) THEN
		XuiCallback (grid, #Selection, -1, 0, 0, 0, 0, grid)
	END IF
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	XgrMessageNameToNumber (@"LastMessage", @upperMessage)
'
' func[#Callback]           = &XuiCallback ()               ' disable to handle Callback messages internally
' func[#GetSmallestSize]    = 0                             ' enable to add internal GetSmallestSize routine
' func[#Resize]             = 0                             ' enable to add internal Resize routine
'
  DIM sub[upperMessage]
  sub[#Callback]            = SUBADDRESS (Callback)         ' enable to handle Callback messages internally
  sub[#Create]              = SUBADDRESS (Create)           ' must be internal routine
  sub[#CreateWindow]        = SUBADDRESS (CreateWindow)     ' must be internal routine
' sub[#GetSmallestSize]     = SUBADDRESS (GetSmallestSize)  ' enable to add internal GetSmallestSize routine
' sub[#Resize]              = SUBADDRESS (Resize)           ' enable to add internal Resize routine
  sub[#Selection]           = SUBADDRESS (Selection)        ' routes Selection callbacks to subroutine
	sub[#TextEvent]						= SUBADDRESS (TextEvent)				'
'
  IF sub[0] THEN PRINT "XitTextCursor() : Initialize : error ::: undefined message Initialize: Error::: Undefined Message"
  IF func[0] THEN PRINT "XitTextCursor() : Initialize : error ::: undefined message Initialize: Error::: Undefined Message"
	XuiRegisterGridType (@XitTextCursor, "XitTextCursor", &XitTextCursor(), @func[], @sub[])
'
' Don't remove the following 4 lines, or WindowFromFunction/WindowToFunction will not work
'
  designX = 256
  designY = 23
  designWidth = 216
  designHeight = 176
'
  gridType = XitTextCursor
	XuiSetGridTypeValue (gridType, @"x",                designX)
	XuiSetGridTypeValue (gridType, @"y",                designY)
	XuiSetGridTypeValue (gridType, @"width",            designWidth)
	XuiSetGridTypeValue (gridType, @"height",           designHeight)
	XuiSetGridTypeValue (gridType, @"maxWidth",         designWidth)
	XuiSetGridTypeValue (gridType, @"maxHeight",        designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",         designWidth)
	XuiSetGridTypeValue (gridType, @"minHeight",        designHeight)
	XuiSetGridTypeValue (gridType, @"border",           $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",              $$Focus OR $$Respond OR $$Callback OR $$TextSelection)
	XuiSetGridTypeValue (gridType, @"focusKid",         $TextCursorColorSample)
	XuiSetGridTypeValue (gridType, @"inputTextString",  $TextCursorColorSample)
  IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' #############################
' #####  XitVariables ()  #####
' #############################
'
FUNCTION  XitVariables (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	STATIC  designX,  designY,  designWidth,  designHeight
	STATIC  SUBADDR	 sub[]
	STATIC  upperMessage
	STATIC  XitVariables
'
	$functionLabel	= 1
	$columnLabel		= 2
	$list						= 3
	$findLabel			= 4
	$findText				= 5
	$valueLabel			= 6
	$valueText			= 7
	$button0				= 8
	$button1				= 9
	$button2				= 10
'
	IFZ sub[] THEN GOSUB Initialize
	IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, XitVariables) THEN RETURN
	GOSUB @sub[message]
	RETURN
'
'
' *****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
	IF (v0 <= 0) THEN v0 = 0
	IF (v1 <= 0) THEN v1 = 0
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiCreateGrid  (@grid, XitVariables, @v0, @v1, @v2, @v3, r0, r1, &XitVariables())
	XuiLabel       (@g, #Create, 4, 4, 752, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiLabel       (@g, #Create, 4, 24, 752, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"type       symbol                location     hex               value")
	XuiList        (@g, #Create, 4, 44, 752, 128, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitVariables(), -1, -1, $list, grid)
	XuiLabel       (@g, #Create, 4, 172, 136, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"find symbol     ")
	XuiTextLine    (@g, #Create, 4, 192, 136, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitVariables(), -1, -1, $findText, grid)
	XuiLabel       (@g, #Create, 140, 172, 616, 20, r0, grid)
	XuiSendMessage ( g, #SetAlign, $$AlignMiddleLeft, $$JustifyLeft, -1, -1, 0, 0)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"new value:")
	XuiTextLine    (@g, #Create, 140, 192, 616, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitVariables(), -1, -1, $valueText, grid)
	XuiPushButton  (@g, #Create, 4, 212, 250, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitVariables(), -1, -1, $button0, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" new value ")
	XuiPushButton  (@g, #Create, 254, 212, 252, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitVariables(), -1, -1, $button1, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" detail ")
	XuiPushButton  (@g, #Create, 506, 212, 250, 20, r0, grid)
	XuiSendMessage ( g, #SetCallback, grid, &XitVariables(), -1, -1, $button2, grid)
	XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" cancel ")
	GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
	IF (v0  = 0) THEN v0 = designX
	IF (v1  = 0) THEN v1 = designY
	IF (v2 <= 0) THEN v2 = designWidth
	IF (v3 <= 0) THEN v3 = designHeight
	XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
	v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
	GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
	XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Variables")
END SUB
'
'
' *****  GetSmallestSize  *****  Return v23 = smallest wh
'
SUB GetSmallestSize
	XuiSendMessage (grid, #GetBorder, @style, 0, 0, 0, 0, @border)
	bw = border
'
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @functionLabelWidth, @functionLabelHeight, $functionLabel, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @columnLabelWidth, @columnLabelHeight, $columnLabel, 16)
	XuiSendToKid (grid, #GetSmallestSize, 20, 4, @listWidth, @listHeight, $list, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @findLabelWidth, @findLabelHeight, $findLabel, 16)
	XuiSendToKid (grid, #GetSmallestSize, 0, 0, @findTextWidth, @findTextHeight, $findText, 16)
'
	buttonWidth = 16
	buttonHeight = 16
	FOR i = $button0 TO $button2
		XuiSendToKid (grid, #GetSmallestSize, 0, 0, @width, @height, i, 16)
		IF (width > buttonWidth) THEN buttonWidth = width
		IF (height > buttonHeight) THEN buttonHeight = height
	NEXT i
	width = buttonWidth + buttonWidth + buttonWidth
	IF (width < functionLabelWidth) THEN width = functionLabelWidth
	IF (width < columnLabelWidth) THEN width = columnLabelWidth
	IF (width < findLabelWidth) THEN width = findLabelWidth
	IF (width < findTextWidth) THEN width = findTextWidth
	IF (width < listWidth) THEN width = listWidth
	v2 = width + bw + bw
	v3 = functionLabelHeight + columnLabelHeight + listHeight
	v3 = v3 + findLabelHeight + findTextHeight+ buttonHeight + bw + bw
	minW = v2
	minH = v3
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize				' returns bw and heights
	v2 = MAX(v2Entry, v2)
	v3 = MAX(v3Entry, v3)
'
'	Resize grid
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
	h = minH
'
	IF (v3 > (h + 4)) THEN
		buttonHeight = buttonHeight + 4									:	h = h + 4
		IF (v3 > (h + 8)) THEN
			functionLabelHeight = functionLabelHeight + 4	:	h = h + 8
			columnLabelHeight = columnLabelHeight + 4
			IF (v3 > (h + 8)) THEN
				findLabelHeight = findLabelHeight + 4
				findTextHeight = findTextHeight + 4
			END IF
		END IF
	END IF
'
'	Resize kids
'
	x = bw
	y = bw
	w = v2 - bw - bw
	h = functionLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $functionLabel, 0)
'
	y = y + h
	h = columnLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $columnLabel, 0)
'
	y = y + h
	h = v3 - functionLabelHeight - columnLabelHeight - findLabelHeight
	h = h - findTextHeight - buttonHeight - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w, h, $list, 0)
'
	y = y + h
	w = findLabelWidth
	h = findLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $findLabel, 0)
	y = y + h
	h = findTextHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $findText, 0)
'
	x = x + w
	y = y - findLabelHeight
	w = v2 - findLabelWidth - bw - bw
	h = findLabelHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $valueLabel, 0)
	y = y + h
	h = findTextHeight
	XuiSendToKid (grid, #Resize, x, y, w, h, $valueText, 0)
'
	x = bw
	y = y + h
	h = buttonHeight
	w1 = (v2 - bw - bw) / 3
	w2 = v2 - w1 - w1 - bw - bw
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button0, 0) : x = x + w1
	XuiSendToKid (grid, #Resize, x, y, w2, h, $button1, 0) : x = x + w2
	XuiSendToKid (grid, #Resize, x, y, w1, h, $button2, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	XuiGetDefaultMessageFuncArray (@func[])
	func[#Callback]						= &XuiCallback()
	func[#GetSmallestSize]		= 0
	func[#GotKeyboardFocus]		= &XuiGotKeyboardFocus()
	func[#LostKeyboardFocus]	= &XuiLostKeyboardFocus()
	func[#Resize]							= 0
	func[#SetKeyboardFocus]		= &XuiSetKeyboardFocus()
'
	DIM sub[#LastMessage]
	sub[#Create]							= SUBADDRESS (Create)
	sub[#CreateWindow]				= SUBADDRESS (CreateWindow)
	sub[#GetSmallestSize]			= SUBADDRESS (GetSmallestSize)
	sub[#Resize]							= SUBADDRESS (Resize)
	IF func[0] THEN PRINT "XitVariables() : Initialize : error ::: undefined message"
	IF sub[0] THEN PRINT "XitVariables() : Initialize : error ::: undefined message"
	XuiRegisterGridType (@XitVariables, @"XitVariables", &XitVariables(), @func[], @sub[])
'
	designX = 0
	designY = 0
	designWidth = 620
	designHeight = 236
'
	gridType = XitVariables
	XuiSetGridTypeValue (gridType, @"x",            designX)
	XuiSetGridTypeValue (gridType, @"y",            designY)
	XuiSetGridTypeValue (gridType, @"width",        designWidth)
	XuiSetGridTypeValue (gridType, @"height",       designHeight)
	XuiSetGridTypeValue (gridType, @"minWidth",     64)
	XuiSetGridTypeValue (gridType, @"minHeight",    32)
	XuiSetGridTypeValue (gridType, @"border",       $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",          $$Focus OR $$Respond OR $$Callback)
	XuiSetGridTypeValue (gridType, @"focusKid",      $findText)
	XuiSetGridTypeValue (gridType, @"redrawFlags",  $$RedrawClearBorder)
	IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ###############################
' #####  AddCommandItem ()  #####
' ###############################
'
FUNCTION  AddCommandItem (text$)
	SHARED  xitGrid
'
	IFZ text$ THEN RETURN
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitCommand, @array$[])
'
	upper = UBOUND (array$[])
'
	IF (upper != 15) THEN
		upper = 15
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		DIM array$[upper]
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
'
	i = upper
	next$ = ""
	this$ = text$
'
	FOR i = 0 TO upper
		SWAP this$, array$[i]
		IF (this$ == text$) THEN EXIT FOR
	NEXT i
'
	array$[0] = text$
	cursorPos = LEN (text$)
	XuiSendMessage (xitGrid, #SetTextString, 0, 0, 0, 0, $$xitCommand, @text$)
	XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitCommand, @array$[])
	XuiSendMessage (xitGrid, #SetTextCursor, cursorPos, 0, 0, 0, $$xitCommand, 0)
	XuiSendMessage (xitGrid, #Redraw, 0, 0, 0, 0, $$xitCommand, 0)
END FUNCTION
'
'
' ##############################
' #####  ImmediateMode ()  #####
' ##############################
'
'	SYNTAX:  .<command>[<space><argument>]
'
'	fn  ft  fl  fs  fm  fr  fq
' ec  eg  ep  ed  eb  ei  ee  ef  er  ew  ea
' vf  vn  vd  vr  vc  vl  vs  vm
' oc  ot
' rs  rc  rj  rp  rk  rr  ra  rl
' dt  dc  de  dm  da  dr
' wc  wr  wx
' hi  hc  hh
'
' key [ # ]
'
'	Commands:
'			All menu bar commands are executed using their 2-letter mnemonic
'				(eg  File-Load  is  .fl)
'				Accept filename args:  ft  fl  fs  fr  er  ew  vm
'				Accept function name:  vv  vn  vd  vr  vc
'				Accept func/file:      vl  vs
'
'				f		<see below>		find immediate
'				r		<see below>		replace immediate
'				c									Clear upper window of text
'				s#								Set tag (a-z)
'				j#								Jump to tag
'				.									Line number and Character number
'				#									show line number #
'				v[-]							view ahead [behind] 1 function
'				a									again (repeat last instruction)
'				h									Help
'
'
' FIND ARGUMENT SYNTAX:
'		SYNTAX:  .[*|<#>][f|r][-][<space><find text>[<tab><replace text>]]
'									[*|<#>]	= repetitions		(* = all instances, default = 1)
'										[f|r]	= find | replace
'											[-]	= reverse
'			[<space>find text]	= a single space delimits the find text
'															(optional: if not specified, last find text is used)
'			[<tab>replace text]	= a single tab (NOT \t) delimits the replace text
'															(optional: if not specified, last replace text is used)
'		Examples:  .*r PIRNT	PRINT
'									|      |
'								space   tab					replace (forward) all instances
'
'		Observations:
'				first char = tab	--	find text$ untouched
'															replace text = text less first tab
'				no text after tab --  replace text = ""
'				Any tabs after first tab are included in replace text
'
FUNCTION  ImmediateMode (keyState)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  jump[],  prog[]
	SHARED  xitGrid
	SHARED  editFilename$,  readFilename$,  writeFilename$
	SHARED  editFunction,  fileType
	SHARED  findText$,  replaceText$,  findReverse,  findReps
	SHARED  environmentActive,  exitMainLoop
	SHARED  fileBox,  renameBox
	SHARED  readBox,  writeBox,  findBox,  funcBox
	SHARED  viewNewBox,  deleteFuncBox,  viewRenameBox,  viewCloneBox
	SHARED  viewLoadBox,  viewSaveBox,  viewMergeBox
	SHARED  memoryBox,  assemblyBox,  registerBox
	SHARED  errorBox,  runtimeErrorBox
	SHARED  optionMiscBox,  textCursor
	SHARED  timeExpired
	SHARED  timeKey$$
	STATIC  lastCommandLine$
	STATIC  FILEINFO  fileinfo[]
'
'	Add newline unless SHIFT-Enter
'
'	PRINT "::: ImmediateMode :::  "; keyState, HEX$(keyState,8)
'
' commented out lines are from old style environment window
'
'	XuiSendMessage (xitGrid, #GetTextCursor, @pos, @cursorLine, 0, 0, $$xitCommand, 0)
'
'	IFZ (keyState AND $$ShiftBit) THEN
'		XuiSendMessage (xitGrid, #TextInsert, 0, 0, 0, $$KeyEnter, $$xitCommand, 0)
'	END IF
'
'	XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitCommand, @text$[])
'
	XuiSendMessage (xitGrid, #GetTextString, 0, 0, 0, 0, $$xitCommand, @text$)
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
	IFZ text$ THEN RETURN ($$FALSE)
'
' commented out lines are from old style environment window
'
'	upper = UBOUND(text$[])
'	IF ((cursorLine < 0) OR (cursorLine > upper)) THEN
'		XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitCommand, @text$[])
'		RETURN ($$FALSE)
'	END IF
'
'	line$ = text$[cursorLine]
'	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitCommand, @text$[])
'	PRINT "line$ = '"; line$; "'"
'
	line$ = text$
	trimLine$ = TRIM$ (text$)
	trimLength = LEN (trimLine$)
	IFZ trimLine$ THEN RETURN ($$FALSE)
	IF (line${0} != '.') THEN RETURN ($$FALSE)
'
	tempCommandLine$ = line$
	key$ = LEFT$ (trimLine$,4)
'
'
' key code used to be here
'
'
	IF ((trimLine$ = ".a") OR (trimLine$ = ".A")) THEN
		lastAgain = $$TRUE
		line$ = lastCommandLine$
		trimLine$ = TRIM$(line$)
	END IF
'
	IF ((trimLine$ = ".") OR (trimLine$ = "..")) THEN
		GOSUB LineImmediate
		IFZ lastAgain THEN
			lastCommandLine$ = tempCommandLine$
		END IF
		RETURN
	END IF
'
	line$ = MID$(line$, 2)
	eow = INCHR(line$, " \t")								' space/tab delimits command word
	SELECT CASE eow
		CASE 0		:	command$ = line$
								argument$ = ""
		CASE 1		:	RETURN ($$FALSE)
		CASE ELSE	:	command$ = MID$(line$, 1, eow - 1)
								argument$ = MID$(line$, eow + 1)
	END SELECT
	arg$ = argument$
	IF argument$ THEN argument$ = TRIM$(argument$)
'
	reps = 1																	' default reps = 1
	digit = command${0}
	SELECT CASE TRUE
		CASE (digit = '*')
					reps= -1
					command$ = MID$(command$, 2)
		CASE (digit >= '0') AND (digit <= '9')	' 0-9
					reps = digit - '0'								' Slicker with XLONG(command$)
					index = 2													'   then INCHR NOT in matchstring
					lenCommand = LEN(command$)
					DO UNTIL (index > lenCommand)
						digit = command${index - 1}
						IF (digit >= '0') AND (digit <= '9') THEN
							reps = reps * 10 + digit - '0'
						ELSE
							EXIT DO
						END IF
						INC index
					LOOP
					command$ = MID$(command$, index)
	END SELECT
'
	command$ = LCASE$(command$)
	SELECT CASE LEN(command$)
		CASE 0														:	GOSUB LineGoto		' .*  or  .###
		CASE 1
			SELECT CASE command${0}
				CASE 'f':												GOSUB FindImmediate
				CASE 'r':												GOSUB FindImmediate
				CASE 'h':												GOSUB HelpImmediate
				CASE 'c':												GOSUB ClearCommand
				CASE 'v':												GOSUB View
			END SELECT
		CASE 2
			SELECT CASE command${0}
				CASE 'f'
					SELECT CASE command${1}
						CASE '-':										GOSUB FindImmediate
						CASE 'n':										GOSUB FileNew
						CASE 't', 'l', 's', 'r':		GOSUB File
						CASE 'm':										GOSUB FileMode
						CASE 'q':										FileQuit ()
					END SELECT
				CASE 'e'
					XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
					SELECT CASE command${1}
						CASE 'c':										EditCut (0)
						CASE 'g':										EditGrab (0)
						CASE 'p':										EditPaste (0)
						CASE 'd':										EditCut (1)
						CASE 'b':										EditGrab (1)
						CASE 'i':										EditPaste (1)
						CASE 'e':										EditCut (-1)
						CASE 'f':										EditFind (findBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
						CASE 'r', 'w':							GOSUB ReadWrite
						CASE 'a':										EditAbandon()
					END SELECT
				CASE 'v':												GOSUB View
				CASE 'o'
					SELECT CASE command${1}
						CASE 'm':										XuiSendMessage (optionMiscBox, #ShowWindow, 0, 0, 0, 0, 0, 0)
						CASE 'c':										GOSUB OptionTextCursor
						CASE 't':										GOSUB OptionTabWidth
					END SELECT
				CASE 'r'
					SELECT CASE command${1}
						CASE '-':										GOSUB FindImmediate
						CASE 's':										RunStart()
						CASE 'c':										RunContinue()
						CASE 'j':										RunJump()
						CASE 'p':										RunPause()
						CASE 'k':										RunKill()
						CASE 'r':										RunRecompile()
						CASE 'a':										RunAssembly()
						CASE 'l':										RunLibrary()
					END SELECT
				CASE 'd'
					SELECT CASE command${1}
						CASE 't':										DebugToggle()
						CASE 'c':										DebugClear()
						CASE 'e':										DebugErase()
						CASE 'm':										XuiSendMessage (memoryBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
						CASE 'a':										DebugAssembly (assemblyBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
						CASE 'r':										DebugRegisters (registerBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
					END SELECT
				CASE 's'
					SELECT CASE command${1}
						CASE 'c':										WizardCompErrors (errorBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
						CASE 'r':										XuiSendMessage (runtimeErrorBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
					END SELECT
				CASE 'h'
					SELECT CASE command${1}
						CASE 'h':										XuiSendMessage (xitGrid, #SetHelp, 0, 0, 0, 0, 0, "readme.txt:*")
						CASE '!':										XuiSendMessage (xitGrid, #SetHelp, 0, 0, 0, 0, 0, "new.hlp:*")
						CASE 'n':										XuiSendMessage (xitGrid, #SetHelp, 0, 0, 0, 0, 0, "notes.hlp:*")
						CASE 's':										XuiSendMessage (xitGrid, #SetHelp, 0, 0, 0, 0, 0, "support.hlp:*")
						CASE 'm':										XuiSendMessage (xitGrid, #SetHelp, 0, 0, 0, 0, 0, "message.hlp:*")
						CASE 'l':										XuiSendMessage (xitGrid, #SetHelp, 0, 0, 0, 0, 0, "language.hlp:*")
						CASE 'o':										XuiSendMessage (xitGrid, #SetHelp, 0, 0, 0, 0, 0, "operator.hlp:*")
						CASE 'd':										XuiSendMessage (xitGrid, #SetHelp, 0, 0, 0, 0, 0, "command.hlp:*")
					END SELECT
				CASE 's':												GOSUB SetTag
				CASE 'j':												GOSUB JumpTag
				CASE 'x':
					SELECT CASE command${1}
						CASE 'i':										HelpIndex ()
						CASE 'c':										HelpContents ()
						CASE 'h':										HelpHighlight ()
					END SELECT
			END SELECT
		CASE ELSE
			IF (command$ = "xit") THEN				GOSUB Xit
	END SELECT
	IFZ lastAgain THEN
		lastCommandLine$ = tempCommandLine$
	END IF
	RETURN
'
'
' *****  ClearCommand  *****
'
SUB ClearCommand
	text$ = ""
	XuiSendMessage (xitGrid, #SetTextString, 0, 0, 0, 0, $$xitCommand, @text$)
	XuiSendMessage (xitGrid, #Redraw, 0, 0, 0, 0, $$xitCommand, 0)
END SUB
'
'
' *****  FileMode  *****
'
SUB FileMode
	IF argument$ THEN arg = argument${0} ELSE arg = 0
	SELECT CASE arg
		CASE 't'	: mode = $$Text
		CASE 'p'	: mode = $$Program
		CASE 'g'	: mode = $$Program
		CASE ELSE	: mode = $$FALSE
	END SELECT
	FileMode (mode)
END SUB
'
'
' *****  FileNew  *****
'
SUB FileNew
	IF argument$ THEN arg = argument${0} ELSE arg = 0
	SELECT CASE arg
		CASE 't'	: arg = $$Text
		CASE 'p'	: arg = $$Program
		CASE 'g'	: arg = $$GuiProgram
		CASE ELSE	: arg = $$FALSE
	END SELECT
	FileNew (arg)
END SUB
'
'
' *****  FileTextLoad  FileLoad  FileSave  FileRename  *****
'
SUB File
	fileName$ = XstPathString$ (@argument$)
	lenName = LEN(fileName$)
'
	SELECT CASE command${1}
		CASE 't'																					' FileTextLoad
					IF fileName$ THEN
'						PRINT "0: ["; editFilename$; "] <"; file$; "> ("; fileName$; ") ", HEX$(attributes,8)
						XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @fileName$)
						XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
						XuiSendMessage (fileBox, #SetTextCursor, lenName, 0, 0, 0, $$FileTextLine, 0)
'						PRINT "1: ["; editFilename$; "] <"; file$; "> ("; fileName$; ") ", HEX$(attributes,8)
						FileTextLoad ($$TRUE)
'						PRINT "2: ["; editFilename$; "] <"; file$; "> ("; fileName$; ") ", HEX$(attributes,8)
					ELSE
						FileTextLoad ($$FALSE)
					END IF
		CASE 'l'																					' FileLoad
					IF fileName$ THEN
'						PRINT "0: ["; editFilename$; "] <"; file$; "> ("; fileName$; ") ", HEX$(attributes,8)
						XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @fileName$)
						XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
						XuiSendMessage (fileBox, #SetTextCursor, lenName, 0, 0, 0, $$FileTextLine, 0)
'						PRINT "1: ["; editFilename$; "] <"; file$; "> ("; fileName$; ") ", HEX$(attributes,8)
						FileLoad ($$TRUE)
'						PRINT "2: ["; editFilename$; "] <"; file$; "> ("; fileName$; ") ", HEX$(attributes,8)
					ELSE
						FileLoad ($$FALSE)
					END IF
		CASE 's'																					' FileSave
					IF fileName$ THEN
'						PRINT "0: ["; editFilename$; "] <"; file$; "> ("; fileName$; ") ", HEX$(attributes,8)
						XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @fileName$)
						XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
						XuiSendMessage (fileBox, #SetTextCursor, lenName, 0, 0, 0, $$FileTextLine, 0)
'						PRINT "1: ["; editFilename$; "] <"; file$; "> ("; fileName$; ") ", HEX$(attributes,8)
						FileSave ($$TRUE)
'						PRINT "2: ["; editFilename$; "] <"; file$; "> ("; fileName$; ") ", HEX$(attributes,8)
					ELSE
						FileSave ($$FALSE)
					END IF
		CASE 'r'																					' FileRename
					IF fileName$ THEN
						XuiSendMessage (renameBox, #SetTextString, 0, 0, 0, 0, 0, @fileName$)
						XuiSendMessage (renameBox, #SetTextString, 0, 0, 0, 0, $$DialogText, @fileName$)
						XuiSendMessage (renameBox, #SetTextCursor, 0, 0, 0, 0, $$DialogText, 0)
						XuiSendMessage (renameBox, #SetTextCursor, lenName, 0, 0, 0, $$DialogText, 0)
						FileRename ($$TRUE)
					ELSE
						FileRename ($$FALSE)
					END IF
	END SELECT
END SUB
'
SUB HelpImmediate
	XuiSendMessage (xitGrid, #SetHelp, 0, 0, 0, 0, 0, "command.hlp:*")
'
'	XuiMessage (@m$)
'
' commented out lines are from old environment window
'
'	XstStringToStringArray (@m$, @text$[])
'	XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitCommand, @text$[])
'	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitCommand, 0)
'	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitCommand, 0)
END SUB
'
SUB LineGoto
	XuiSendMessage (xitGrid, #SetTextCursor, 0, reps, -1, -1, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
END SUB
'
SUB ReadWrite
	filename$ = XstPathString$ (@argument$)
	lenName = LEN (filename$)
	IF (command$ = "er") THEN
		readFilename$ = filename$
		XuiSendMessage (readBox, #SetTextString, 0, 0, 0, 0, 0, @filename$)
		XuiSendMessage (readBox, #SetTextCursor, lenName, 0, 0, 0, $$FileTextLine, 0)
		IFZ readFilename$ THEN EditRead ($$FALSE) ELSE EditRead ($$TRUE)
	ELSE
		writeFilename$ = filename$
		XuiSendMessage (writeBox, #SetTextString, 0, 0, 0, 0, 0, @filename$)
		XuiSendMessage (writeBox, #SetTextCursor, lenName, 0, 0, 0, $$FileTextLine, 0)
		IFZ writeFilename$ THEN EditWrite ($$FALSE) ELSE EditWrite ($$TRUE)
	END IF
END SUB
'
SUB FindImmediate
	IFZ reps THEN
		Message (".f find : 0 repititions requested")
		EXIT SUB
	END IF
'
	IF (LEN(command$) = 2) THEN										' f-  r-
		findReverse = $$TRUE
		command$ = LEFT$(command$, 1)
	ELSE
		findReverse = $$FALSE
	END IF
	XuiSendMessage (findBox, #SetValues, findReverse, 0, 0, 0, $$FindReverseToggle, 0)
'
	IF (command$ = "f") THEN
		IF (reps < 0) THEN reps = 1
	END IF
'
	IF LEN(arg$) THEN									' if no argument, findText$/replaceText$ untouched
		itab = INSTR (arg$, "\t")
		SELECT CASE itab
			CASE 0
				findText$ = arg$						' no tab, replaceText$ untouched
				XuiSendMessage (findBox, #SetTextString, 0, 0, 0, 0, $$FindFindText, @findText$)
				XuiSendMessage (findBox, #RedrawText, 0, 0, 0, 0, $$FindFindText, 0)
				IF (INSTR(findText$, "\\")) THEN
					findText$ = XstBackStringToBinString$ (@findText$)
				END IF
			CASE 1
				replaceText$ = MID$(arg$, 2)				' <tab>... findText$ untouched
				XuiSendMessage (findBox, #SetTextString, 0, 0, 0, 0, $$FindReplaceText, @replaceText$)
				XuiSendMessage (findBox, #RedrawText, 0, 0, 0, 0, $$FindReplaceText, 0)
				IF (INSTR(replaceText$, "\\")) THEN
					replaceText$ = XstBackStringToBinString$ (@replaceText$)
				END IF
			CASE ELSE:
				findText$ = MID$(arg$, 1, itab - 1)
				XuiSendMessage (findBox, #SetTextString, 0, 0, 0, 0, $$FindFindText, @findText$)
				XuiSendMessage (findBox, #RedrawText, 0, 0, 0, 0, $$FindFindText, 0)
				IF (INSTR(findText$, "\\")) THEN
					findText$ = XstBackStringToBinString$ (@findText$)
				END IF
				replaceText$ = MID$(arg$, itab + 1)
				XuiSendMessage (findBox, #SetTextString, 0, 0, 0, 0, $$FindReplaceText, @replaceText$)
				XuiSendMessage (findBox, #RedrawText, 0, 0, 0, 0, $$FindReplaceText, 0)
				IF (INSTR(replaceText$, "\\")) THEN
					replaceText$ = XstBackStringToBinString$ (@replaceText$)
				END IF
		END SELECT
	END IF
'
	IF (reps = -1) THEN
		reps$ = "*"
	ELSE
		reps$ = STRING$(reps)
	END IF
	XuiSendMessage (findBox, #SetTextString, 0, 0, 0, 0, $$FindRepsText, @reps$)
	XuiSendMessage (findBox, #RedrawText, 0, 0, 0, 0, $$FindRepsText, 0)
'
	findReps = reps
	IF (command$ = "f") THEN
		FindSearch()
	ELSE
		ReplaceSearch()
	END IF
END SUB
'
SUB SetTag
	char = LCASE$(command$){1}
	IF ((char < 'a') OR (char > 'z')) THEN EXIT SUB
	i = char - 'a'
	IF (fileType = $$Program) THEN
		jump[i, 0] = editFunction
	END IF
	XuiSendMessage (xitGrid, #GetTextCursor, 0, @cursorLine, 0, 0, $$xitTextLower, 0)
	jump[i, 1] = cursorLine
END SUB
'
SUB JumpTag
	char = LCASE$(command$){1}
	IF ((char < 'a') OR (char > 'z')) THEN EXIT SUB
	i = char - 'a'
	IF (fileType = $$Program) THEN
		Display (jump[i, 0], jump[i, 1], 0, -1, -1)
	ELSE
		XuiSendMessage (xitGrid, #SetTextCursor, 0, jump[i, 1], -1, -1, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
	END IF
END SUB
'
SUB LineImmediate
	XuiSendMessage (xitGrid, #GrabTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, 0, 0, $$xitTextLower, 0)
	lastLine = 0
	lastPos = 0
	IF text$[] THEN
		lastLine = UBOUND(text$[])
		lastPos = LEN(text$[lastLine])

		totalChars = 0
		FOR line = 0 TO lastLine
			IF (line = cursorLine) THEN lineChars = totalChars + cursorPos
			totalChars = totalChars + LEN(text$[line]) + 1
		NEXT line
		XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	END IF
'
	m$ = "line = " + STRING$(cursorLine) + "/" + STRING$(lastLine)
	m$ = m$ + "  xPos = " + STRING$(cursorPos)
	m$ = m$ + "  char = " + STRING$(lineChars) + "/"
	m$ = m$ + STRING$(totalChars)
'
'	m$ = m$ + "\n"
'
	AddCommandItem (@m$)
'	XuiSendMessage (xitGrid, #GetTextArrayBounds, 0, 0, @lastPos, @lastLine, $$xitCommand, 0)
'	XuiSendMessage (xitGrid, #TextReplace, lastPos, lastLine, lastPos, lastLine, $$xitCommand, @m$)
'	XuiSendMessage (xitGrid, #SetTextCursor, 0, lastLine + 2, 0, 0, $$xitCommand, 0)
'	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitCommand, 0)
END SUB
'
SUB View
	IF (fileType != $$Program) THEN
		Message (" ViewImmediate \n\n invalid on text file ")
		EXIT SUB
	END IF
	functionName$ = TRIM$(argument$)
	lenName = LEN(functionName$)
'
	IF (command$ == "v") THEN
		IFZ functionName$ THEN
			forward = $$TRUE
			GOSUB ViewFunctionSkip
			EXIT SUB
		ELSE
			command$ = "vv"
		END IF
	END IF
'
	IF (command$ == "v-") THEN
		IFZ functionName$ THEN
			forward = $$FALSE
			GOSUB ViewFunctionSkip
			EXIT SUB
		ELSE
			command$ = "vv"
		END IF
	END IF
'
	SELECT CASE command${1}
		CASE '0':	Display (0, -1, -1, -1, -1)												' view PROLOG - always exists
		CASE 'v':	IFZ functionName$ THEN
								ViewFunc (funcBox, #DisplayWindow, 0, 0, 0, 0, 0, @"")
							ELSE
								ViewFunc (funcBox, #View, 0, 0, 0, 0, 0, @functionName$)
							END IF
		CASE 'f':	IFZ functionName$ THEN
								ViewFunc (funcBox, #DisplayWindow, 0, 0, 0, 0, 0, @"")
							ELSE
								ViewFunc (funcBox, #View, 0, 0, 0, 0, 0, @functionName$)
							END IF
		CASE 'p':	ViewPriorFunc()
		CASE 'n':	XuiSendMessage (viewNewBox, #SetTextString, lenName, 0, 0, 0, $$DialogText, @functionName$)
							XuiSendMessage (viewNewBox, #SetTextCursor, lenName, 0, 0, 0, $$DialogText, 0)
							ViewNewFunc    (viewNewBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		CASE 'd':	ViewDeleteFunc (deleteFuncBox, #DisplayWindow, 0, 0, 0, 0, 0, @functionName$)
		CASE 'r':	XuiSendMessage (viewRenameBox, #SetTextString, lenName, 0, 0, 0, $$DialogText, @functionName$)
							XuiSendMessage (viewRenameBox, #SetTextCursor, lenName, 0, 0, 0, $$DialogText, 0)
							ViewRenameFunc ($$TRUE)
		CASE 'c':	XuiSendMessage (viewCloneBox, #SetTextString, lenName, 0, 0, 0, $$DialogText, @functionName$)
							XuiSendMessage (viewCloneBox, #SetTextCursor, lenName, 0, 0, 0, $$DialogText, 0)
							ViewCloneFunc ($$TRUE)
		CASE 'l':	IF functionName$ THEN
								index = 1 : done = 0
								funcName$ = TRIM$(XstNextField$(@functionName$, @index, @done))
								lenName = LEN(funcName$)
								XuiSendMessage (viewLoadBox, #SetTextString, lenName, 0, 0, 0, 2, @funcName$)
								XuiSendMessage (viewLoadBox, #SetTextCursor, lenName, 0, 0, 0, 2, 0)
								IFZ done THEN
									fileName$ = TRIM$(MID$(functionName$, index))
									lenName = LEN (fileName$)
									XuiSendMessage (viewLoadBox, #SetTextString, lenName, 0, 0, 0, 4, @fileName$)
									XuiSendMessage (viewLoadBox, #SetTextCursor, lenName, 0, 0, 0, 4, 0)
								END IF
							END IF
							ViewLoadFunc ($$TRUE)
		CASE 's':	IF functionName$ THEN
								index = 1 : done = 0
								funcName$ = TRIM$(XstNextField$(@functionName$, @index, @done))
								lenName = LEN(funcName$)
								XuiSendMessage (viewSaveBox, #SetTextString, lenName, 0, 0, 0, 2, @funcName$)
								XuiSendMessage (viewSaveBox, #SetTextCursor, lenName, 0, 0, 0, 2, 0)
								IFZ done THEN
									fileName$ = TRIM$(MID$(functionName$, index))
									lenName = LEN(fileName$)
									XuiSendMessage (viewSaveBox, #SetTextString, lenName, 0, 0, 0, 4, @fileName$)
									XuiSendMessage (viewSaveBox, #SetTextCursor, lenName, 0, 0, 0, 4, 0)
								END IF
							ELSE
								IFZ editFunction THEN
									funcName$ = "PROLOG"
								ELSE
									XxxFunctionName ($$XGET, @funcName$, editFunction)
								END IF
								lenName = LEN(funcName$)
								XuiSendMessage (viewSaveBox, #SetTextString, lenName, 0, 0, 0, 2, @funcName$)
								XuiSendMessage (viewSaveBox, #SetTextCursor, lenName, 0, 0, 0, 2, 0)
							END IF
							ViewSaveFunc ($$TRUE)
		CASE 'm':	IF functionName$ THEN				' actually, fileName$
								lenName = LEN(functionName$)
								XuiSendMessage (viewMergeBox, #SetTextString, lenName, 0, 0, 0, $$DialogText, @functionName$)
								XuiSendMessage (viewMergeBox, #SetTextCursor, lenName, 0, 0, 0, $$DialogText, 0)
							END IF
							ViewMergePROLOG ($$TRUE)
		CASE 'i': ViewImportFunctionFromProgram (0)
	END SELECT
END SUB
'
' goes forward/backward 1 function by funcNumber (wraps around)
'
SUB ViewFunctionSkip
	IF ((fileType != $$Program) OR (prog[] == 0)) THEN
		Message (" error \n\n no program loaded ")
		EXIT SUB
	END IF
'
	IF forward THEN
		funcNumber = editFunction + 1
		DO UNTIL (funcNumber > maxFuncNumber)
			IF prog[funcNumber,] THEN
				Display (funcNumber, -1, -1, -1, -1)		' old cursor Position
				EXIT SUB
			END IF
			INC funcNumber
		LOOP
	ELSE
		funcNumber = editFunction - 1
		IF (funcNumber < 0) THEN funcNumber = maxFuncNumber
		DO UNTIL (funcNumber <= 0)
			IF prog[funcNumber,] THEN
				Display (funcNumber, -1, -1, -1, -1)		' old cursor Position
				EXIT SUB
			END IF
			DEC funcNumber
		LOOP
	END IF
'
	Display (0, -1, -1, -1, -1)										' PROLOG always exists
END SUB
'
SUB OptionTabWidth
	arg = 0
	IF argument$ THEN
		first = argument${0}
		SELECT CASE TRUE
			CASE  (first = 'a')												: arg = 64	' assembly
			CASE  (first = 'p')												: arg = 16	' program
			CASE  (first = 'x')												: arg = 16	' xbasic
			CASE ((first >= '0') AND (first <= '9'))	: arg = XLONG (argument$)
		END SELECT
	END IF
	OptionTabWidth (arg)
END SUB
'
SUB OptionTextCursor
	color = 0
	IF argument$ THEN
		color = XLONG(argument$)
		IF ((color >= 1) AND (color <= 124)) THEN
			XuiSendMessage (textCursor, #HideWindow, 0, 0, 0, 0, 0, 0)
			XxxXuiTextCursor (color)
		END IF
	ELSE
		XuiSendMessage (textCursor, #DisplayWindow, 0, 0, 0, 0, 0, 0)
	END IF
END SUB
'
SUB Xit																' goto low-level Xit debugger
	exitMainLoop = $$TRUE
	environmentActive = $$FALSE
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN XitSoftBreak()
END SUB
END FUNCTION
'
'
' ########################
' #####  FileNew ()  #####  Create new Text, Program, GuiProgram.
' ########################  Erase current source (confirm if not saved).
'
FUNCTION  FileNew (newFileType)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  jump[]
	SHARED  uprog,  fileBox,  environmentActive
	SHARED  xitGrid,  newBox,  fileType,  funcBox,  deleteFuncBox
	SHARED  editFilename$,  textAlteredSinceLastSave
'
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		IF environmentActive THEN
			message$ = "??? terminate program execution ???"
			warningResponse = WarningResponse (@message$, @" new ", "")
			IF (warningResponse = $$WarningCancel) THEN RETURN
		END IF
		XxxSetBlowback ()
		AddDispatch (&FileNew(), 0)				' execute blowback first
		RETURN
	END IF
'
	SELECT CASE newFileType
		CASE $$Text
		CASE $$Program
		CASE $$GuiProgram
		CASE ELSE						: newFileType = 0		' unspecified
	END SELECT
'
	IF environmentActive THEN
		IF textAlteredSinceLastSave THEN
			IF (fileType = $$Program) THEN
				message$ = "FileNew()\nprogram not saved"
			ELSE
				message$ = "FileNew()\ntext not saved"
			END IF
			warningResponse = WarningResponse (@message$, @" new ", @" save ")
			SELECT CASE warningResponse
				CASE $$WarningOption	: abort = FileSave ($$FALSE)
																IF abort THEN RETURN
				CASE $$WarningCancel	: RETURN
			END SELECT
		END IF
	END IF
'
	IFZ newFileType THEN
		response = 0
		XuiSendMessage (newBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
		newFileType = $$Text
		gui = $$FALSE
		SELECT CASE response
			CASE 0		:	IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
									newFileType = $$Text
			CASE 2		:	newFileType = $$Text
			CASE 3		:	newFileType = $$Program
			CASE 4		:	newFileType = $$GuiProgram
			CASE 5		:	RETURN
			CASE ELSE	:	PRINT "FileNew() : unknown responses ="; response
									RETURN
		END SELECT
	END IF
'
	DIM name$[]
	XuiSendMessage (funcBox, #SetTextArray, 0, 0, 0, 0, 2, @name$[])
	XuiSendMessage (funcBox, #SetTextString, 0, 0, 0, 0, 3, @"")
	XuiSendMessage (funcBox, #RedrawText, 0, 0, 0, 0, 2, 0)
	XuiSendMessage (funcBox, #RedrawText, 0, 0, 0, 0, 3, 0)
	XuiSendMessage (deleteFuncBox, #SetTextArray, 0, 0, 0, 0, 2, @name$[])
	XuiSendMessage (deleteFuncBox, #SetTextString, 0, 0, 0, 0, 3, @"")
	XuiSendMessage (deleteFuncBox, #RedrawText, 0, 0, 0, 0, 2, 0)
	XuiSendMessage (deleteFuncBox, #RedrawText, 0, 0, 0, 0, 3, 0)
'
	SELECT CASE newFileType
		CASE $$Text						: GOSUB NewText
		CASE $$Program				: GOSUB NewProgram
		CASE $$GuiProgram			: GOSUB NewGuiProgram
	END SELECT
'
	ResetDataDisplays ($$ResetAssembly)
	DIM jump[25,1]															' Clear jump tags
	editFilename$ = ""
	XstGetCurrentDirectory (@dir$)
	XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @dir$)
	XuiSendMessage (fileBox, #Update, 0, 0, 0, 0, 0, 0)
	textAlteredSinceLastSave = $$FALSE
	IF gui THEN textAlteredSinceLastSave = $$TRUE
	UpdateFileFuncLabels ($$TRUE, $$TRUE)				'	Reset file/function names
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
	RETURN
'
'
' *****  NewText  *****
'
SUB NewText
	DIM text$[]
	XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
	DIM prog[]															' free prog[]
	DIM funcAltered[]
	DIM funcBPAltered[]
	DIM funcNeedsTokenizing[]
	DIM funcCursorPosition[]
	XuiSendMessage (funcBox, #HideWindow, 0, 0, 0, 0, 0, 0)
	XuiSendMessage (deleteFuncBox, #HideWindow, 0, 0, 0, 0, 0, 0)
	maxFuncNumber = 0
	fileType = $$Text
END SUB
'
'
' *****  NewProgram  *****
'
SUB NewProgram
	error = $$FALSE
	fileType = $$Program
	error = XstLoadStringArray (@"$XBDIR/templates/prolog.xxx", @text$[])
	IF error THEN DefaultFunctionText (0, @text$[])
	aborted = ConvertTextToProg ($$TextArray, @text$[], $$AbortAllowed)
	IF aborted THEN GOSUB AbortLoad : RETURN
	error = XitLoadFunction (@"Entry", @"$XBDIR/templates/entry.xxx")
	IF error THEN Message (" could not load $XBDIR/templates/entry.xxx ")
	XitSetDisplayedFunction (@"Entry")
END SUB
'
'
' *****  NewGuiProgram  *****
'
SUB NewGuiProgram
	error = $$FALSE
	fileType = $$Program
	error = XstLoadStringArray (@"$XBDIR/templates/gprolog.xxx", @text$[])
	IF error THEN Message (" could not load $XBDIR/templates/gprolog.xxx" ) : RETURN
	aborted = ConvertTextToProg ($$TextArray, @text$[], $$AbortAllowed)
	IF aborted THEN GOSUB AbortLoad : RETURN
	error = XitLoadFunction (@"Entry", @"$XBDIR/templates/gentry.xxx")
	IF error THEN Message (" could not load $XBDIR/templates/gentry.xxx ") : GOSUB AbortLoad : RETURN
	error = XitLoadFunction (@"InitGui", @"$XBDIR/templates/initgui.xxx")
	IF error THEN Message (" could not load $XBDIR/templates/initgui.xxx ") : GOSUB AbortLoad : RETURN
	error = XitLoadFunction (@"InitProgram", @"$XBDIR/templates/initprog.xxx")
	IF error THEN Message (" could not load $XBDIR/templates/initprog.xxx ") : GOSUB AbortLoad : RETURN
	error = XitLoadFunction (@"CreateWindows", @"$XBDIR/templates/create.xxx")
	IF error THEN Message (" could not load $XBDIR/templates/create.xxx ") : GOSUB AbortLoad : RETURN
	error = XitLoadFunction (@"InitWindows", @"$XBDIR/templates/initwins.xxx")
	IF error THEN Message (" could not load $XBDIR/templates/initwins.xxx ") : GOSUB AbortLoad : RETURN
END SUB
'
'
' *****  AbortLoad  *****
'
SUB AbortLoad
	IF (fileType = $$Program) THEN
		Message (" no new program \n\n resident program removed ")
		DIM text$[]
		XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
		fileType = $$Text
		DIM prog[]														' free prog[]
		DIM funcAltered[]
		DIM funcBPAltered[]
		DIM funcNeedsTokenizing[]
		DIM funcCursorPosition[]
		uprog = 0
		maxFuncNumber = 0
		editFilename$ = ""
		XstGetCurrentDirectory (@dir$)
		XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @dir$)
		XuiSendMessage (fileBox, #Update, 0, 0, 0, 0, 0, 0)
		textAlteredSinceLastSave = $$FALSE
		UpdateFileFuncLabels ($$TRUE, $$TRUE)
		ResetDataDisplays ($$ResetAssembly)
	ELSE
		Message (" no new text \n\n current text retained ")
	END IF
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
END SUB
END FUNCTION
'
'
' #############################
' #####  FileTextLoad ()  #####
' #############################
'
FUNCTION  FileTextLoad (skipUpdate)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  jump[]
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  fileBox,  funcBox,  deleteFuncBox
	SHARED  xitGrid,  fileType,  editFilename$
	SHARED  textAlteredSinceLastSave,  environmentActive
	SHARED  sigNumber
'
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		IF environmentActive THEN
			message$ = "??? terminate program execution ???"
			warningResponse = WarningResponse (@message$, @" new ", "")
			IF (warningResponse = $$WarningCancel) THEN RETURN
		END IF
		XxxSetBlowback ()
		AddDispatch (&FileTextLoad(), 0)					' execute blowback first
		RETURN
	END IF
'
	IF environmentActive THEN
		IF textAlteredSinceLastSave THEN
			IF (fileType = $$Program) THEN
				message$ = "FileTextLoad()\nprogram has not been saved"
			ELSE
				message$ = "FileTextLoad()\ntext has not been saved"
			END IF
			warningResponse = WarningResponse (@message$, @" load ", @" save ")
			SELECT CASE warningResponse
				CASE $$WarningOption	: abort = FileSave ($$FALSE)
																IF abort THEN RETURN
				CASE $$WarningCancel	: RETURN
			END SELECT
		END IF
	END IF
'
	ClearRuntimeError ()
'
	XuiSendMessage (fileBox, #GetTextString, 0, 0, 0, 0, 0, @file$)
	length = LEN (file$)
	XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #SetTextCursor, length, 0, 0, 0, $$FileTextLine, 0)
'
	XstGuessFilename (@editFilename$, @file$, @fileName$, @attributes)
	IF (attributes AND $$FileDirectory) THEN skipUpdate = $$FALSE
	IFZ attributes THEN skipUpdate = $$FALSE
'
	IF skipUpdate THEN
		XstGetFileAttributes (@fileName$, @attributes)
		IFZ attributes THEN skipUpdate = $$FALSE
	END IF
'
	length = LEN(fileName$)
	XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @fileName$)
	XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #SetTextCursor, length, 0, 0, 0, $$FileTextLine, 0)
'
	IFZ skipUpdate THEN
		XuiSendMessage (fileBox, #Update, 0, 0, 0, 0, 0, 0)
		XuiSendMessage (fileBox, #SetKeyboardFocus, 0, 0, 0, 0, $$FileTextLine, 0)
		XuiSendMessage (fileBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:FileTextLoad")
		XuiSendMessage (fileBox, #GetModalInfo, @v0, 0, 0, 0, 0, 0)
		XuiSendMessage (fileBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:SelectFile")
'
		SELECT CASE v0
			CASE -1			:	RETURN						' KeyEscape or Cancel
			CASE 2,6,7	:										' text/file, OK button
			CASE ELSE		:	PRINT "FileTextLoad() : unknown response ="; v0
										RETURN
		END SELECT
		XuiSendMessage (fileBox, #GetTextString, 0, 0, 0, 0, 0, @fileName$)
	END IF
'
	XstGetFileAttributes (@fileName$, @attributes)
'
	SELECT CASE TRUE
		CASE (attributes = 0)
					Message (" FileTextLoad() \n\n cannot find file \n\n " + fileName$)
					RETURN
		CASE (attributes AND $$FileDirectory)
					Message (" FileTextLoad() \n\n invalid file type \n\n " + fileName$)
					RETURN
	END SELECT
'
' Open file, check its size, make string of nulls, read file into the string
'
	ifile = OPEN (fileName$, $$RD)
'
	IF (ifile < 0) THEN
		Message (" FileTextLoad() \n\n error opening file \n\n " + fileName$)
		RETURN
	END IF
'
	IF (fileType = $$Program) THEN
		DIM prog[]																			' free prog[]
		DIM funcAltered[]
		DIM funcBPAltered[]
		DIM funcNeedsTokenizing[]
		DIM funcCursorPosition[]
		uprog = 0
		maxFuncNumber = 0
		fileType = $$Text
		ResetDataDisplays ($$ResetAssembly)
	END IF
'
	DIM text$[]
	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
'
	editFilename$ = fileName$
	lenName = LEN (editFilename$)
	XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @editFilename$)
	XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #SetTextCursor, lenName, 0, 0, 0, $$FileTextLine, 0)
	IFZ skipUpdate THEN XuiSendMessage (fileBox, #Update, 0, 0, 0, 0, 0, 0)
	textAlteredSinceLastSave = $$FALSE
	UpdateFileFuncLabels ($$TRUE, $$TRUE)
'
	DIM name$[]
	XuiSendMessage (funcBox, #SetTextArray, 0, 0, 0, 0, 2, @name$[])
	XuiSendMessage (funcBox, #SetTextString, 0, 0, 0, 0, 3, @"")
	XuiSendMessage (funcBox, #HideWindow, 0, 0, 0, 0, 0, 0)
	XuiSendMessage (deleteFuncBox, #SetTextArray, 0, 0, 0, 0, 2, @name$[])
	XuiSendMessage (deleteFuncBox, #SetTextString, 0, 0, 0, 0, 3, @"")
	XuiSendMessage (deleteFuncBox, #HideWindow, 0, 0, 0, 0, 0, 0)
'
	DIM jump[25,1]																	' Clear jump tags
'
	ifileSize = LOF (ifile)
	IFZ ifileSize THEN
		CLOSE (ifile)
		Message (" FileTextLoad() \n\n file has no contents ")
		RETURN
	END IF
'
	SetCurrentStatus ($$StatusLoading, 0)
	text$ = NULL$ (ifileSize)
	READ [ifile], text$
	CLOSE (ifile)
'
' Put loaded string into the text widget, set up editFilename$ and fileType
'		TextArea converts to array
'
	XstStringToStringArray (@text$, @text$[])
	text$ = ""																			' free text$ immediately
	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
END FUNCTION
'
'
' #########################
' #####  FileLoad ()  #####
' #########################
'
FUNCTION  FileLoad (skipUpdate)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  jump[]
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  uprog
	SHARED  fileBox,  editFilename$,  editFunction,  xitGrid
	SHARED  textAlteredSinceLastSave,  fileType,  funcBox,  deleteFuncBox
	SHARED  sigNumber,  environmentActive
	SHARED  entryStatus
'
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		IF environmentActive THEN
			message$ = "??? terminate program execution ???"
			warningResponse = WarningResponse (@message$, @" new ", "")
			IF (warningResponse = $$WarningCancel) THEN RETURN
		END IF
		XxxSetBlowback ()
		AddDispatch (&FileLoad(), 0)					' execute blowback first
		RETURN
	END IF
'
	IF environmentActive THEN
		IF textAlteredSinceLastSave THEN
			IF (fileType = $$Program) THEN
				message$ = "FileLoad()\nprogram has not been saved"
			ELSE
				message$ = "FileLoad()\ntext has not been saved"
			END IF
			warningResponse = WarningResponse (@message$, @" load ", @" save ")
			SELECT CASE warningResponse
				CASE $$WarningOption	: abort = FileSave ($$FALSE)
																IF abort THEN RETURN
				CASE $$WarningCancel	: RETURN
			END SELECT
		END IF
	END IF
'
	ClearRuntimeError ()
'
	XuiSendMessage (fileBox, #GetTextString, 0, 0, 0, 0, 0, @file$)
	length = LEN (file$)
	XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #SetTextCursor, length, 0, 0, 0, $$FileTextLine, 0)
'
	XstGuessFilename (@editFilename$, @file$, @fileName$, @attributes)
	IF (attributes AND $$FileDirectory) THEN skipUpdate = $$FALSE
	IFZ attributes THEN skipUpdate = $$FALSE
'
	IF skipUpdate THEN
		XstGetFileAttributes (@fileName$, @attributes)
		IFZ attributes THEN skipUpdate = $$FALSE
	END IF
'
	length = LEN(fileName$)
	XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @fileName$)
	XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #SetTextCursor, length, 0, 0, 0, $$FileTextLine, 0)
'
	IFZ skipUpdate THEN
		XuiSendMessage (fileBox, #Update, 0, 0, 0, 0, 0, 0)
		XuiSendMessage (fileBox, #SetKeyboardFocus, 0, 0, 0, 0, $$FileTextLine, 0)
		XuiSendMessage (fileBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:FileLoad")
		XuiSendMessage (fileBox, #GetModalInfo, @v0, 0, 0, 0, 0, 0)
		XuiSendMessage (fileBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:SelectFile")
'
		SELECT CASE v0
			CASE -1			:	RETURN						' KeyEscape or Cancel
			CASE 2,6,7	:	' text/file, OK button
			CASE ELSE		:	PRINT "FileLoad() : unknown response ="; v0
										RETURN
		END SELECT
		XuiSendMessage (fileBox, #GetTextString, 0, 0, 0, 0, 0, @fileName$)
	END IF
'
	xsuffix = INSTR (fileName$, ".")
	IFZ xsuffix THEN fileName$ = fileName$ + ".x"
'
	IF (LCASE$(RIGHT$(fileName$, 2)) != ".x") THEN
		message$ = " '" + fileName$ + "' \n\n is an invalid file name \n\n must end with .x "
		Message (@message$)
		RETURN
	END IF
'
	XstGetFileAttributes (@fileName$, @attributes)
	SELECT CASE TRUE
		CASE (attributes = 0)
			Message (" FileLoad() \n\n cannot find file \n\n " + fileName$)
			RETURN
		CASE (attributes AND $$FileDirectory)
			Message (" FileLoad() \n\n invalid file type \n\n " + fileName$)
			RETURN
	END SELECT
'
	ifile  = OPEN (fileName$, $$RD)
	IF (ifile < 0) THEN
		Message (" FileLoad() \n\n cannot open file \n\n " + fileName$)
		RETURN
	END IF
'
'	Waste current program now
'
	DIM text$[]
	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
'
	DIM name$[]
	XuiSendMessage (funcBox, #SetTextArray, 0, 0, 0, 0, 2, @name$[])
	XuiSendMessage (funcBox, #SetTextString, 0, 0, 0, 0, 3, @"")
	XuiSendMessage (funcBox, #HideWindow, 0, 0, 0, 0, 0, 0)
	XuiSendMessage (deleteFuncBox, #SetTextArray, 0, 0, 0, 0, 2, @name$[])
	XuiSendMessage (deleteFuncBox, #SetTextString, 0, 0, 0, 0, 3, @"")
	XuiSendMessage (deleteFuncBox, #HideWindow, 0, 0, 0, 0, 0, 0)
'
	editFunction = 0
	fileType = $$Program
	editFilename$ = fileName$
	lenName = LEN (editFilename$)
	XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @editFilename$)
	XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #SetTextCursor, lenName, 0, 0, 0, $$FileTextLine, 0)
	IFZ skipUpdate THEN XuiSendMessage (fileBox, #Update, 0, 0, 0, 0, 0, 0)
	textAlteredSinceLastSave = $$FALSE
	UpdateFileFuncLabels ($$TRUE, $$TRUE)
'
	ClearRuntimeError ()
'
	DIM jump[25,1]																	' Clear jump tags
'
	ifileSize = LOF (ifile)
	IFZ ifileSize THEN
		Message (" FileLoad() \n\n file has no contents \n\n " + fileName$ + " ")
		CLOSE (ifile)
		GOTO AbortLoad
	END IF
'
	SetCurrentStatus ($$StatusLoading, 0)
'
	text$ = NULL$ (ifileSize)							' appends terminating NULL
	READ [ifile], text$
	CLOSE (ifile)
	IFZ TextHasNonWhites ($$TextString, @text$) THEN
		Message (" FileLoad() \n\n file contains non text \n\n " + fileName$ + " ")
		GOTO AbortLoad
	END IF
'
	aborted = ConvertTextToProg ($$TextString, @text$, $$AbortAllowed)
	IF aborted THEN
		Message (" FileLoad() \n\n aborted ")
		GOTO AbortLoad
	END IF
'
	fileType = $$Program
	ResetDataDisplays ($$ResetAssembly)
	RETURN
'
AbortLoad:
	DIM prog[]																				' free prog[]
	DIM funcAltered[]
	DIM funcBPAltered[]
	DIM funcNeedsTokenizing[]
	DIM funcCursorPosition[]
	uprog = 0
	maxFuncNumber = 0
	editFilename$ = ""
	XstGetCurrentDirectory (@dir$)
	x = LEN (dir$)
	XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @dir$)
	XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #SetTextCursor, x, 0, 0, 0, $$FileTextLine, 0)
	IFZ skipUpdate THEN XuiSendMessage (fileBox, #Update, 0, 0, 0, 0, 0, 0)
	fileType = $$Text
	UpdateFileFuncLabels ($$TRUE, $$TRUE)
	ResetDataDisplays ($$ResetAssembly)
END FUNCTION
'
'
' #########################
' #####  FileSave ()  #####
' #########################
'
FUNCTION  FileSave (skipUpdate)
	SHARED  prog[],  sigs[]
	SHARED  xitGrid,  fileBox,  fileType,  textAlteredSinceLastSave
	SHARED  defaultDirectory$,  editFilename$
	SHARED  saveCRLF
'
	XuiSendMessage (fileBox, #GetTextString, 0, 0, 0, 0, 0, @file$)
	length = LEN (file$)
	XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #SetTextCursor, length, 0, 0, 0, $$FileTextLine, 0)
'
	XstGuessFilename (@editFilename$, @file$, @fileName$, @attributes)
	IF (attributes AND $$FileDirectory) THEN skipUpdate = $$FALSE
	IFZ attributes THEN skipUpdate = $$FALSE
'
	length = LEN(fileName$)
	XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @fileName$)
	XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #SetTextCursor, length, 0, 0, 0, $$FileTextLine, 0)
'
	IFZ skipUpdate THEN
		XuiSendMessage (fileBox, #Update, 0, 0, 0, 0, 0, 0)
		XuiSendMessage (fileBox, #SetKeyboardFocus, 0, 0, 0, 0, $$FileTextLine, 0)
		XuiSendMessage (fileBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:FileSave")
		XuiSendMessage (fileBox, #GetModalInfo, @v0, 0, 0, 0, 0, 0)
		XuiSendMessage (fileBox, #SetHelpString, -1, 0, 0, 0, 0, @"pde.hlp:SelectFile")
'
		SELECT CASE v0
			CASE -1			:	RETURN (-1)						' KeyEscape or Cancel
			CASE 2,6,7	:	' text/file, OK button
			CASE ELSE		:	PRINT "FileSave() : unknown response ="; v0
										RETURN (-1)
		END SELECT
		XuiSendMessage (fileBox, #GetTextString, 0, 0, 0, 0, 0, @fileName$)
	END IF
'
	fileName$ = TRIM$(fileName$)
'
	IFZ fileName$ THEN
		Message (" FileSave() \n\n !!! file not saved !!! \n\n need file name ")
		RETURN (-1)
	END IF
'
	XstGetFileAttributes (@fileName$, @attributes)
	IF (attributes AND $$FileDirectory) THEN
		Message (" FileSave() \n\n !!! file not saved !!! \n\n file name is a directory \n\n " + fileName$ + " ")
		RETURN (-1)
	END IF
'
	IF attributes THEN
		message$ = "FileSave()\nfilename already exists\n" + fileName$
		warningResponse = WarningResponse (@message$, @" save ", "")
		IF (warningResponse = $$WarningCancel) THEN RETURN (-1)
	END IF
'
	SELECT CASE fileType
		CASE $$Text			:	GOSUB SaveFileText
		CASE $$Program	:	GOSUB SaveFileProgram
	END SELECT
	RETURN (0)
'
'
'	*****  Save the environment TEXT to a disk file  *****
'
SUB SaveFileText
	ofile = OPEN (fileName$, $$WRNEW)
	IF (ofile < 0) THEN
		Message (" FileSave() \n\n !!! file not saved !!! \n\n unable to open file \n\n \"" + fileName$ + "\" ")
		RETURN (-1)
	END IF
'
	SetCurrentStatus ($$StatusSaving, 0)
'
' write text to file
'
	XuiSendMessage (xitGrid, #GrabTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	IF text$[] THEN
		IF saveCRLF THEN
			XstStringArrayToStringCRLF (@text$[], @text$)		' \r\n
		ELSE
			XstStringArrayToString (@text$[], @text$)				' \n
		END IF
		XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		##ERROR = $$FALSE
		WRITE [ofile], text$
		IF ##ERROR THEN
			Message (" FileSave() \n\n !!! file not saved !!! \n\n write to file failed ")
			CLOSE (ofile)
			RETURN (-1)
		END IF
		IF (LEN(text$) != LOF(ofile)) THEN
			Message (" FileSave() \n\n !!! file not saved !!! \n\n write to file failed ")
			CLOSE (ofile)
			RETURN (-1)
		END IF
	END IF
	CLOSE (ofile)
	editFilename$ = fileName$
	textAlteredSinceLastSave = $$FALSE
'
'	Reset file name
'
	UpdateFileFuncLabels ($$TRUE, 0)
END SUB
'
'
'	*****  Save the environment PROGRAM to a disk file  *****
'
SUB SaveFileProgram
'
' Note:  if ##USERRUNNING then text is unaltered and Restore.. does nothing
	redisplay = $$TRUE
	reportBogusRename = $$TRUE						' tokenize, resets BPs if necessary
	RestoreTextToProg (redisplay, reportBogusRename)
'
	aborted = ConvertProgToText ($$TextString, saveCRLF, $$AbortAllowed, @text$)
	IF aborted THEN
		Message (" FileSave() \n\n !!! file not saved !!! \n\n aborted ")
		RETURN (-1)
	END IF
'
	ofile = OPEN (fileName$, $$WRNEW)
	IF (ofile < 0) THEN
		Message (" FileSave() \n\n !!! file not saved !!! \n\n can't open file \n\n \"" + fileName$ + "\" ")
		RETURN (-1)
	END IF
'
	SetCurrentStatus ($$StatusSaving, 0)
'
	##ERROR = $$FALSE
	WRITE [ofile], text$
	IF ##ERROR THEN
		Message (" FileSave() \n\n !!! file not saved !!! \n\n write to file failed ")
		CLOSE (ofile)
		RETURN (-1)
	END IF
	IF (LEN(text$) != LOF(ofile)) THEN
		Message (" FileSave() \n\n !!! file not saved !!! \n\n write to file failed ")
		CLOSE (ofile)
		RETURN (-1)
	END IF
	CLOSE (ofile)
'
	editFilename$ = fileName$
	textAlteredSinceLastSave = $$FALSE
'
'	Reset file name
'
	UpdateFileFuncLabels ($$TRUE, 0)
'
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN
		SetCurrentStatus ($$StatusRunning, 0)
	END IF
END SUB
END FUNCTION
'
'
' #########################
' #####  FileMode ()  #####
' #########################
'
FUNCTION  FileMode (mode)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[],  jump[]
	SHARED  environmentActive
	SHARED  uprog
	SHARED  modeBox
	SHARED  xitGrid
	SHARED  fileType
	SHARED  editFilename$
'
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		IF environmentActive THEN
			message$ = "??? terminate program execution ???"
			warningResponse = WarningResponse (@message$, @" MODE ", "")
			IF (warningResponse = $$WarningCancel) THEN RETURN
		END IF
		XxxSetBlowback ()
		AddDispatch (&FileMode(), 0)					' execute blowback first
		RETURN
	END IF
'
	IF environmentActive THEN
		IF textAlteredSinceLastSave THEN
			IF (fileType = $$Program) THEN
				message$ = "FileMode()\nprogram not saved"
			ELSE
				message$ = "FileMode()\ntext not saved"
			END IF
			warningResponse = WarningResponse (@message$, @" mode ", @" save ")
			SELECT CASE warningResponse
				CASE $$WarningOption	: FileSave ($$FALSE)
																RETURN
				CASE $$WarningCancel	: RETURN
			END SELECT
		END IF
	END IF
'
	response = 0
	SELECT CASE mode
		CASE $$Text				: modeType = $$Text
		CASE $$Program		: modeType = $$Program
		CASE $$GuiProgram	: modeType = $$Program
		CASE ELSE					: modeType = 0
	END SELECT
'
	IFZ modeType THEN
		modeType = $$Text
		XuiSendMessage (modeBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
		SELECT CASE response
			CASE 0		:	IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
									modeType = $$Program
			CASE 2		:	modeType = $$Program
			CASE 3		:	modeType = $$Text
			CASE 4		:	RETURN
			CASE ELSE	:	PRINT "FileMode() : unknown response ="; response
									RETURN
		END SELECT
	END IF
'
	IF (modeType = $$Program) THEN
		IF (fileType = $$Program) THEN RETURN								' wise guy
		XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		IFZ TextHasNonWhites ($$TextArray, @text$[]) THEN		' fix NULL
			XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			DefaultFunctionText (0, @text$[])									' whiz up a PROLOG
			aborted = ConvertTextToProg ($$TextArray, @text$[], $$AbortAllowed)
		ELSE
'
'			Convert from string:  ConvertTextToProg mangles array...
'
			XstStringArrayToString (@text$[], @text$)				' \n
			XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			aborted = ConvertTextToProg ($$TextString, @text$, $$AbortAllowed)
		END IF
'
		IF aborted THEN
			Message (" FileMode() \n\n mode unchanged \n\n current text retained \n\n conversion aborted ")
			XuiSendMessage (xitGrid, #RedrawText, 0, 0, $$SelectCancel, 0, $$xitTextLower, 0)
			RETURN
		END IF
		fileType = $$Program
		UpdateFileFuncLabels (0, $$TRUE)
		ResetDataDisplays ($$ResetAssembly)
	ELSE
		IF (fileType = $$Text) THEN RETURN		' wise guy
		redisplay = $$TRUE
		reportBogusRename = $$TRUE						' tokenize, resets BPs if necessary
		RestoreTextToProg (redisplay, reportBogusRename)
		ClearRuntimeError ()
		aborted = ConvertProgToText ($$TextArray, 0, $$AbortAllowed, @text$[])
		IF aborted THEN
			Message (" FileMode() \n\n mode not changed \n\n conversion aborted ")
			RETURN
		END IF
		fileType = $$Text
		XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
'
		DIM prog[]														' free prog[]
		DIM funcAltered[]
		DIM funcBPAltered[]
		DIM funcNeedsTokenizing[]
		DIM funcCursorPosition[]
		uprog = 0
		maxFuncNumber = 0
		UpdateFileFuncLabels (0, $$TRUE)
		ResetDataDisplays ($$ResetAssembly)
	END IF
	DIM jump[25,1]													' Clear jump tags
END FUNCTION
'
'
' ###########################
' #####  FileRename ()  #####
' ###########################
'
FUNCTION  FileRename (skipUpdate)
	SHARED  fileBox
	SHARED  fileType
	SHARED  renameBox
	SHARED  editFilename$
	SHARED  defaultDirectory$
'
	XuiSendMessage (renameBox, #GetTextString, 0, 0, 0, 0, $$DialogText, @newName$)
'
	IFZ skipUpdate THEN
		IF (newName$ != editFilename$) THEN
			lenName = LEN (editFilename$)
			XuiSendMessage (renameBox, #SetTextString, lenName, 0, 0, 0, $$DialogText, @editFilename$)
			XuiSendMessage (renameBox, #SetTextCursor, lenName, 0, 0, 0, $$DialogText, 0)
		END IF
	END IF
'
	IFZ skipUpdate THEN
		response = 0
		XuiSendMessage (renameBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
		SELECT CASE response
			CASE 2		:	IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
			CASE 3		:	' OK button
			CASE 4		:	RETURN
			CASE ELSE	:	PRINT "FileRename() : unknown response ="; response
									RETURN
		END SELECT
		XuiSendMessage (renameBox, #GetTextString, 0, 0, 0, 0, $$DialogText, @newName$)
	END IF
'
	IFZ newName$ THEN
		Message (" FileRename() \n\n no file name specified ")
		RETURN
	END IF
'
	IF ((fileType = $$Program) OR (fileType = $$GuiProgram)) THEN
		dot = INSTR (newFile$, ".")
		IFZ dot THEN newFile$ = newFile$ + ".x"
		IF (RIGHT$(newFile$,2) != ".x") THEN
			Message (" FileRename() \n\n did not rename \n\n name must end with .x ")
			RETURN
		END IF
	END IF
'
	XstGetFileAttributes (@newName$, @attributes)
	SELECT CASE TRUE
		CASE (attributes AND $$FileDirectory)
			Message (" FileRename() \n\n error \n\n invalid file name \n\n " + newName$)
			RETURN
		CASE attributes
			Message (" FileRename() \n\n warning \n\n file already exists \n\n " + newName$)
	END SELECT
'
'	Reset file name
'
	lenName = LEN (newName$)
	XuiSendMessage (fileBox, #SetTextString, 0, 0, 0, 0, 0, @newName$)
	XuiSendMessage (fileBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #SetTextCursor, lenName, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (fileBox, #Update, 0, 0, 0, 0, 0, 0)
	editFilename$ = newName$
	UpdateFileFuncLabels ($$TRUE, 0)
END FUNCTION
'
'
' #########################
' #####  FileQuit ()  #####
' #########################
'
FUNCTION  FileQuit ()
	XitQuit (0)
END FUNCTION
'
'
' ########################
' #####  EditCut ()  #####
' ########################
'
FUNCTION  EditCut (bufferNumber)
	SHARED  xitGrid,  xitTextLower
	UBYTE  null[]
'
	XgrGetTextSelectionGrid (@grid)
	IF grid THEN
		XuiSendMessage (grid, #GetTextSelection, @begPos, @begLine, @endPos, @endLine, 0, @text$)
		IFZ text$ THEN RETURN
		IF (grid = xitTextLower) THEN
'			v2 = ($$KeyDelete << 24) OR $$KeyDelete OR 0x00080000
			v2 = ($$KeyDelete << 24) OR $$KeyDelete OR 0x00000000
			r0 = $$xitTextLower
			EnvironmentCode (xitGrid, #TextEvent, 0, 0, v2, 0, @r0, 0)
			IF (r0 = -1) THEN RETURN
		END IF
		IF (bufferNumber >= 0) THEN XgrSetClipboard (bufferNumber, $$ClipboardTypeText, @text$, @null[])
		IF text$ THEN																		' cut selection
			XuiSendMessage (grid, #TextReplace, begPos, begLine, endPos, endLine, 0, "")
			XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, 0, 0)
		END IF
	END IF
END FUNCTION
'
'
' #########################
' #####  EditGrab ()  #####
' #########################
'
FUNCTION  EditGrab (bufferNumber)
	SHARED	xitGrid
	UBYTE  null[]
'
	XgrGetTextSelectionGrid (@grid)
	IF grid THEN
		XuiSendMessage (grid, #GetTextSelection, @x1, @y1, @x2, @y2, 0, @text$)
		XuiSendMessage (grid, #RedrawText, 0, 0, $$SelectCancel, 0, 0, 0)
		IFZ text$ THEN RETURN
		XgrSetClipboard (bufferNumber, $$ClipboardTypeText, @text$, @null[])
	END IF
END FUNCTION
'
'
' ##########################
' #####  EditPaste ()  #####
' ##########################
'
FUNCTION  EditPaste (bufferNumber)
	SHARED  xitGrid,  xitCommand,  xitTextLower
	UBYTE  null[]
'
'	PRINT "EditPaste().a "; bufferNumber
	XgrGetClipboard (bufferNumber, $$ClipboardTypeText, @text$, @null[])
'	PRINT "EditPaste().b "; text$
	IF text$ THEN
		XgrGetSelectedWindow (@window)
		XgrSendMessage (window, #WindowGetKeyboardFocusGrid, @focusGrid, 0, 0, 0, 0, 0)
'		PRINT "EditPaste().c "; focusGrid, xitTextLower, xitCommand
		IFZ focusGrid THEN
			Message (" EditPaste \n\n no grid with keyboard focus ")
			RETURN
		END IF
		XuiSendMessage (focusGrid, #GetTextSelection, @begPos, @begLine, @endPos, @endLine, 0, @select$)
'		PRINT "EditPaste().d "; cursorPos, cursorLine
		IF (focusGrid == xitTextLower) THEN
'			v2 = ($$KeyInsert << 24) OR $$KeyInsert OR 0x00080000
			v2 = ($$KeyInsert << 24) OR $$KeyInsert
			r0 = $$xitTextLower
			EnvironmentCode (xitGrid, #TextEvent, 0, 0, v2, 0, @r0, 0)
			IF (r0 = -1) THEN RETURN
		END IF
'		PRINT "EditPaste().e "; HEX$(v2,8)
		XuiSendMessage (focusGrid, #TextReplace, begPos, begLine, endPos, endLine, 0, @text$)
		XuiSendMessage (focusGrid, #RedrawText, 0, 0, 0, 0, 0, 0)
	END IF
'	PRINT "EditPaste().z"
END FUNCTION
'
'
' #########################
' #####  EditFind ()  #####
' #########################
'
FUNCTION  EditFind (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	SHARED  findText$,  replaceText$,  findReps
	SHARED  findCase,  findLocal,  findReverse
'
	SELECT CASE message
		CASE #Callback				: GOSUB Callback
		CASE #DisplayWindow		: GOSUB DisplayWindow		' Direct
		CASE #FindForward			: GOSUB Execute					' Direct
		CASE #FindReverse			: GOSUB Execute					' Direct
		CASE #ReplaceForward	: GOSUB Execute					' Direct
		CASE #ReplaceReverse	: GOSUB Execute					' Direct
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****
'
SUB DisplayWindow
	XgrGetTextSelectionGrid (@textSelectionGrid)
	IF textSelectionGrid THEN
		XuiSendMessage (textSelectionGrid, #GetTextSelection, 0, 0, 0, 0, 0, @select$)
		IF select$ THEN
			lenName = LEN (select$)
			XuiSendMessage (textSelectionGrid, #RedrawText, 0, 0, $$SelectCancel, 0, 0, 0)
			XuiSendMessage (grid, #SetTextString, lenName, 0, 0, 0, $$FindFindText, @select$)
			XuiSendMessage (grid, #SetTextCursor, lenName, 0, 0, 0, $$FindFindText, 0)
		END IF
	END IF
	XuiSendToKid (grid, #DisplayWindow, 0, 0, 0, 0, 1, 0)
END SUB
'
'
' *****  Execute  *****  For Hot button execution only
'
SUB Execute
	findReverse = $$FALSE
	SELECT CASE message
		CASE  #FindReverse, #ReplaceReverse:	findReverse = $$TRUE
	END SELECT
'
	findReps = 1
	XuiSendMessage (grid, #SetTextString, 1, 0, 0, 0, $$FindRepsText, @"1")
	XuiSendMessage (grid, #SetTextCursor, 1, 0, 0, 0, $$FindRepsText, 0)
	XuiSendMessage (grid, #SetValues, findReverse, 0, 0, 0, $$FindReverseToggle, 0)
'
	SELECT CASE message
		CASE #FindForward	: FindSearch ()
		CASE #FindReverse	: FindSearch ()
		CASE ELSE					: ReplaceSearch ()
	END SELECT
END SUB
'
'
' *****  Selection  *****
'
SUB Selection
	SELECT CASE r0
		CASE $$FindCaseToggle
					findCase = $$FALSE
					IF v0 THEN findCase = $$TRUE
		CASE $$FindLocalToggle
					findLocal = $$FALSE
					IF v0 THEN findLocal = $$TRUE
		CASE $$FindReverseToggle
					findReverse = $$FALSE
					IF v0 THEN findReverse = $$TRUE
		CASE $$FindFindText, $$FindReplaceText, $$FindRepsText
					IF (v0{$$VirtualKey} = $$KeyEscape) THEN
						XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)		' CANCEL
					ELSE
						r0 = $$FindFindButton
						GOSUB FindReplace																				' FIND
					END IF
		CASE $$FindCancelButton
					XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE $$FindFindButton, $$FindReplaceButton
					GOSUB FindReplace
	END SELECT
END SUB
'
'
' *****  FindReplace  *****
'
SUB FindReplace
	XuiSendMessage (grid, #GetTextString, 0, 0, 0, 0, $$FindFindText, @findText$)
	IF (INSTR (findText$, "\\")) THEN
		findText$ = XstBackStringToBinString$ (@findText$)
	END IF
	XuiSendMessage (grid, #GetTextString, 0, 0, 0, 0, $$FindReplaceText, @replaceText$)
	IF (INSTR (replaceText$, "\\")) THEN
		replaceText$ = XstBackStringToBinString$ (@replaceText$)
	END IF
	XuiSendMessage (grid, #GetTextString, 0, 0, 0, 0, $$FindRepsText, @reps$)
	IF (reps$ = "*") THEN
		findReps = -1
	ELSE
		findReps = XLONG(reps$)
	END IF
	IFZ findText$ THEN
		Message (" EditFind() \n\n no find text specified ")
		RETURN
	END IF
	IFZ findReps THEN
		Message (" EditFind() \n\n 0 repititions requested ")
		RETURN
	END IF
	IF (r0 = $$FindFindButton) THEN
		FindSearch ()
	ELSE
		ReplaceSearch ()
	END IF
END SUB
END FUNCTION
'
'
' ###########################
' #####  FindSearch ()  #####
' ###########################
'
'	Find routine (based on SHARED parameters)
'
'	In:				none
'	Out:			none
'
'	Discussion:
'		All functions are frozen for the search.  The editFunction text is
'			carried in text$[], all the other functions use progText$.
'			When the final match is made, if it is not in editFunction, then
'			editFunction is Restored and the match function displayed.
'
FUNCTION  FindSearch ()
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcCursorPosition[]
	SHARED  xitGrid,  editFunction,  priorFunction
	SHARED  findBox,  findReverse,  findReps,  findText$
	SHARED  fileType,  softInterrupt
	SHARED  findCase,  findLocal
	SHARED  currentCursor
	SHARED	freezeState
'
	IF freezeState THEN RETURN				' not recursive - causes stack blowup
	entryCursor = currentCursor
	softInterrupt = $$FALSE
'
' Skip it if no text selected
'
	IFZ findText$ THEN
		Message (" FindSearch() \n\n no find string specified ")
		RETURN (-1)
	END IF
'
'	Skip it if 0 reps requested
'
	IFZ findReps THEN
		Message (" FindSearch() \n\n 0 repititions requested ")
		RETURN (-1)
	END IF
	IF (findReps < 0) THEN
		findReps = 1
		XuiSendMessage (findBox, #SetTextString, 0, 0, 0, 0, $$FindRepsText, @"1")
	END IF
	reps = findReps
'	SetCursor ($$CursorWait)
	IF findCase THEN
		mode = $$FindForward OR $$FindCaseSensitive
		IF findReverse THEN mode = $$FindReverse OR $$FindCaseSensitive
	ELSE
		mode = $$FindForward OR $$FindCaseInsensitive
		IF findReverse THEN mode = $$FindReverse OR $$FindCaseInsensitive
	END IF
'
	freezeState = $$TRUE											' can't start another replace
'
' $$Text and $$Program first check the current text widget
'
	XuiSendMessage (xitGrid, #GrabTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, 0, @topLine, $$xitTextLower, 0)
	skip = $$TRUE																' skip if cursor at a match
	FindArray (mode, @text$[], @findText$, cursorLine, cursorPos, @reps, skip, @matches[])
	IFZ reps THEN GOTO matchInText
'
' TEXT/LOCAL only checks from cursor to end of text
'
	IF (fileType != $$Program) OR (findLocal = $$TRUE) THEN GOTO noMatch
	IFZ prog[] THEN GOTO noMatch
	skip = $$FALSE
	IF maxFuncNumber THEN												'	Do global check of rest of PROGRAM
		i = 0
		funcNumber = editFunction
		DO
			IF findReverse THEN
				DEC funcNumber
				IF (funcNumber < 0) THEN funcNumber = maxFuncNumber
			ELSE
				INC funcNumber
				IF (funcNumber > maxFuncNumber) THEN funcNumber = 0
			END IF
			IF (funcNumber = editFunction) THEN EXIT DO			' Stop before editFunction
			IFZ prog[funcNumber,] THEN DO DO
			SetCurrentStatus ($$StatusSearching, i)					' Clears queue
			IF softInterrupt THEN GOTO noMatch
			TokenArrayToText (funcNumber, @progText$[])
			IF findReverse THEN
				line = UBOUND(progText$[])
				pos = LEN(progText$[line])
			ELSE
				line = 0
				pos = 0
			END IF
			FindArray (mode, @progText$[], @findText$, line, pos, @reps, skip, @matches[])
			IFZ reps THEN GOTO matchInProg
			INC i
		LOOP
	END IF
'
' Now check other half of text
'
	SELECT CASE TRUE
		CASE findReverse
			IF (cursorLine = uText) THEN							' already tested entire text?
				IF (cursorPos >= LEN(text$[cursorLine])) THEN EXIT SELECT
			END IF
			line = uText
			pos = LEN(text$[uText])
			FindArray (mode, @text$[], @findText$, line, pos, @reps, skip, @matches[])
			IFZ reps THEN
				match = UBOUND(matches[])
				line = matches[match,0]
				pos = matches[match,1]
				IF (line < cursorLine) THEN EXIT SELECT
				IF (line = cursorLine) THEN
					IF (pos <= cursorPos) THEN EXIT SELECT
				END IF
				GOTO matchInText
			END IF
		CASE ELSE
			IF (cursorLine = 0) THEN									' already tested entire text
				IF (cursorPos = 0) THEN EXIT SELECT
			END IF
			line = 0
			pos = 0
			FindArray (mode, @text$[], @findText$, line, pos, @reps, skip, @matches[])
			IFZ reps THEN
				match = UBOUND(matches[])
				line = matches[match,0]
				pos = matches[match,1]
				IF (line > cursorLine) THEN EXIT SELECT
				IF (line = cursorLine) THEN
					IF (pos >= cursorPos) THEN EXIT SELECT
				END IF
				GOTO matchInText
			END IF
	END SELECT
'
noMatch:
	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	IF softInterrupt THEN
		Message (" FindSearch() \n\n interrupted ")
	ELSE
		backText$ = XstBinStringToBackStringNL$ (@findText$)
		Message (" FindSearch() \n\n no match found for \n\n '" + backText$ + "' ")
	END IF
'	SetCursor (entryCursor)
	freezeState = $$FALSE
	RETURN (-1)

matchInText:
	match = UBOUND (matches[])
	cursorLine = matches[match,0]
	cursorPos = matches[match,1]
	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, cursorPos, cursorLine, 0, topLine, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
	IF (fileType = $$Program) THEN
		XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
'		XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
		funcCursorPosition[editFunction, 0] = cursorLine
		funcCursorPosition[editFunction, 1] = cursorPos
		funcCursorPosition[editFunction, 2] = topLine
		funcCursorPosition[editFunction, 3] = topIndent
'		funcCursorPosition[editFunction, 4] = xCursor
'		funcCursorPosition[editFunction, 5] = yCursor
	END IF

'	SetCursor (entryCursor)
	freezeState = $$FALSE
	RETURN (cursorChar)

matchInProg:												' match, not in editFunction
	match = UBOUND (matches[])
	cursorLine = matches[match,0]
	cursorPos = matches[match,1]
	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
	redisplay = $$FALSE
	reportBogusRename = $$TRUE
	RestoreTextToProg (redisplay, reportBogusRename)			' out with the old...
	priorFunction = editFunction
	editFunction = funcNumber
	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @progText$[])
	XuiSendMessage (xitGrid, #SetTextCursor, cursorPos, cursorLine, 0, topLine, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
	funcCursorPosition[editFunction, 0] = cursorLine
	funcCursorPosition[editFunction, 1] = cursorPos
	funcCursorPosition[editFunction, 2] = topLine
	funcCursorPosition[editFunction, 3] = topIndent
	funcCursorPosition[editFunction, 4] = xCursor
	funcCursorPosition[editFunction, 5] = yCursor

	UpdateFileFuncLabels (0, $$TRUE)							' Reset function name
'	SetCursor (entryCursor)
	freezeState = $$FALSE
	RETURN
END FUNCTION
'
'
' ##############################
' #####  ReplaceSearch ()  #####
' ##############################
'
'	Replace routine (based on SHARED parameters)
'
'	In:				none
'	Out:			none
'
'	Discussion:
'		Renaming functions is not allowed during replace (or manual mod for that
'			matter).  The function is converted to text and an unmonitored replace
'			is executed.  The text is retokenized, and if the function happened
'			to be renamed, the name is overwritten with the original name.
'			(Function renaming must be done with the ViewRename)
'		In PROGRAM mode, if the text is made NULL by the replace, it is filled
'			with the default FUNCTION...END FUNCTION code (as in View New Function).
'		If replaces restricted to editFunction, don't retokenize--this will
'			happen naturally as the environment is used.
'
'		If scanning across functions:
'			1)  editFunction 1st scan:  don't retokenize; wait till 2nd scan.
'			2)  each function:
'						progText$[] = deparsed function
'						apply replace to progText$[]
'						if changes
'								- If empty, replace with FUNCTION...END FUNCTION minimum.
'								- retokenize (overwrites rename, if any)
'								- ATTACH array back onto prog
'			3)  editFunction remaining half:
'						if any changes to editFunction,
'								- If empty, replace with FUNCTION...END FUNCTION minimum.
'								- retokenize (overwrites rename, if any)
'								- ATTACH array back onto prog
'
FUNCTION  ReplaceSearch ()
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  xitGrid,  findReverse,  findReps
	SHARED  findText$,  replaceText$,  fileType
	SHARED  editFunction,  softInterrupt
	SHARED  findCase,  findLocal
	SHARED  programAltered,  textAlteredSinceLastSave
	SHARED  currentCursor
	SHARED	freezeState
'
	IF freezeState THEN RETURN				' not recursive - causes stack blowup
	entryCursor = currentCursor
	softInterrupt = $$FALSE
'
' Skip it if no text selected
'
	IFZ findText$ THEN
		Message (" ReplaceSearch() \n\n no find string specified ")
		RETURN
	END IF
'
'	Skip it if 0 reps requested
'
	IFZ findReps THEN
		Message (" ReplaceSearch() \n\n 0 repititions requested ")
		RETURN
	END IF
'
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		message$ = "ReplaceSearch()\ncannot REPLACE while program executes"
		warningResponse = WarningResponse (@message$, @" TERMINATE ", "")
		IF (warningResponse = $$WarningCancel) THEN RETURN
		XxxSetBlowback ()
		RETURN
	END IF
'
	reps = findReps
'	SetCursor ($$CursorWait)
'
	IF findCase THEN
		mode = $$FindForward OR $$FindCaseSensitive
		IF findReverse THEN mode = $$FindReverse OR $$FindCaseSensitive
	ELSE
		mode = $$FindForward OR $$FindCaseInsensitive
		IF findReverse THEN mode = $$FindReverse OR $$FindCaseInsensitive
	END IF
'
	freezeState = $$TRUE											' can't start another replace
'
	lastFunctionFound = editFunction
	XuiSendMessage (xitGrid, #GrabTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, 0, @topLine, $$xitTextLower, 0)
	skip = $$FALSE																' reverse: skip if cursor at a match
	IF findReverse THEN skip = $$TRUE
	line = cursorLine
	pos = cursorPos
	ReplaceArray (mode, @text$[], @findText$, @replaceText$, @line, @pos, @reps, skip)
	IF (reps < findReps) THEN
		IFZ textAlteredSinceLastSave THEN
			textAlteredSinceLastSave = $$TRUE
			UpdateFileFuncLabels ($$TRUE, 0)
		END IF
		editFunctionChanged = $$TRUE
		IF (fileType = $$Program) THEN
			funcAltered[editFunction] = $$TRUE
			funcNeedsTokenizing[editFunction] = $$TRUE
		END IF
		lastEditLine = line
		lastEditPos = pos
		skip = $$TRUE					' xxx add 01/01/94
	END IF
'
	IF ((fileType = $$Text) OR findLocal OR (reps = 0)) THEN
		IFZ editFunctionChanged THEN
			XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			XuiSendMessage (xitGrid, #SetTextCursor, pos, line, 0, topLine, $$xitTextLower, 0)
			GOTO noMatch
		END IF
		IF (fileType = $$Text) THEN
			XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			XuiSendMessage (xitGrid, #SetTextCursor, pos, line, 0, topLine, $$xitTextLower, 0)
			XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
		ELSE
			IFZ TextHasNonWhites ($$TextArray, @text$[]) THEN			' fix empty
				DefaultFunctionText (funcNumber, @text$[])
				XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
				XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
			ELSE
				XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
				XuiSendMessage (xitGrid, #SetTextCursor, pos, line, 0, topLine, $$xitTextLower, 0)
			END IF
			XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
			XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
			XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
			funcCursorPosition[editFunction, 0] = cursorLine
			funcCursorPosition[editFunction, 1] = cursorPos
			funcCursorPosition[editFunction, 2] = topLine
			funcCursorPosition[editFunction, 3] = topIndent
			funcCursorPosition[editFunction, 4] = xCursor
			funcCursorPosition[editFunction, 5] = yCursor
		END IF
		IFZ textAlteredSinceLastSave THEN
			textAlteredSinceLastSave = $$TRUE
			UpdateFileFuncLabels ($$TRUE, 0)						' reset file name
		END IF
'
		XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
'		SetCursor (entryCursor)
		freezeState = $$FALSE
		RETURN
	END IF
'
'	$$Program AND NOT findLocal AND more reps to go:
'
'	1)  editFunction 1st scan:  don't retokenize; wait till 2nd scan.
'
	renameAttempts = 0
'
'	2)  each function:
'				progText$ = deparsed function
'				apply replace to progText$
'				if changes
'						- If empty, replace with FUNCTION...END FUNCTION minimum.
'						- retokenize (overwrites rename, if any)
'						- ATTACH array back onto prog
'
	skip = $$FALSE												' reverse: skip if cursor at a match
	IF maxFuncNumber THEN									' Do global test of rest of PROGRAM
		i = 0
		funcNumber = editFunction
		DO
			IF findReverse THEN
				DEC funcNumber
				IF (funcNumber < 0) THEN funcNumber = maxFuncNumber
			ELSE
				INC funcNumber
				IF (funcNumber > maxFuncNumber) THEN funcNumber = 0
			END IF
			IF (funcNumber = editFunction) THEN EXIT DO	' Stop before editFunction
			IFZ prog[funcNumber,] THEN DO DO
'
			SetCurrentStatus ($$StatusSearching, i)					' Clears queue
			TokenArrayToText (funcNumber, @progText$[])
			IF softInterrupt THEN
				IF (reps = findReps) THEN GOTO noMatch				' Nothing changed, put text$[] back in TextArea
				GOTO replaceProg
			END IF
'
			line = 0 : pos = 0
			IF findReverse THEN
				line = UBOUND(progText$[])
				pos = LEN(progText$[line])
			END IF
			startReps = reps
			ReplaceArray (mode, @progText$[], @findText$, @replaceText$, @line, @pos, @reps, skip)
			IFZ reps THEN
				lastFunctionFound = funcNumber
				GOTO replaceProg
			END IF
'
			IF (reps < startReps) THEN									' Tokenize: don't allow rename (freeze)
				lastFunctionFound = funcNumber
				IFZ TextHasNonWhites ($$TextArray, @progText$[]) THEN		' fix empty
					DefaultFunctionText (funcNumber, @progText$[])
				END IF
				freeze = $$TRUE
				bogusFunction = TextToTokenArray (@progText$[], @func[], funcNumber, freeze)
				ATTACH prog[funcNumber,] TO temp[]				' Waste old array
				DIM temp[]
				ATTACH func[] TO prog[funcNumber,]
				funcAltered[funcNumber] = $$TRUE
				funcNeedsTokenizing[funcNumber] = $$FALSE
'
				funcCursorPosition[funcNumber, 0] = line	' reset cursorChar / topChar
				funcCursorPosition[funcNumber, 1] = pos
				funcCursorPosition[funcNumber, 2] = -1
				funcCursorPosition[funcNumber, 3] = 0
				funcCursorPosition[funcNumber, 4] = 0
				funcCursorPosition[funcNumber, 5] = -1
'				PRINT "rx0", cursorLine, cursorPos, line, pos
				IFZ funcNumber THEN prologAltered = $$TRUE
				IF bogusFunction THEN INC renameAttempts	' rename attempt squashed
				skip = $$TRUE					' xxx add 01/01/94
			END IF
			INC i
		LOOP
	END IF
'
'	Now check other half of editFunction
'		3)  editFunction 2nd scan:
'					if any changes to editFunction,
'							- If empty, replace with FUNCTION...END FUNCTION minimum.
'							- retokenize (overwrites rename, if any)
'							- ATTACH array back onto prog
'
'	PRINT "rx1", cursorLine; cursorPos; line; pos
	SELECT CASE TRUE
		CASE findReverse
			IF (cursorLine = uText) THEN											' already tested entire text?
				IF (cursorPos >= LEN(text$[cursorLine])) THEN EXIT SELECT
			END IF
'
'			Create end half array
'
			uText = UBOUND(text$[])
			IF ((cursorLine = 0) AND (cursorPos <= 0)) THEN
				entireText = $$TRUE
				SWAP text$[], endText$[]
				uEndText = uText
			ELSE
				entireText = $$FALSE
				uEndText = uText - cursorLine
				DIM endText$[uEndText]
				endText$[0] = MID$(text$[cursorLine], cursorPos + 1)
				IF uEndText THEN
					endText = 1
					FOR i = cursorLine + 1 TO uText
						ATTACH text$[i] TO endText$[endText]
						INC endText
					NEXT i
				END IF
			END IF
			line = uEndText
			pos = LEN(endText$[uEndText])
			startReps = reps
			ReplaceArray (mode, @endText$[], @findText$, @replaceText$, @line, @pos, @reps, skip)
			IF (reps < startReps) THEN
				lastFunctionFound = editFunction
				editFunctionChanged = $$TRUE
				funcAltered[editFunction] = $$TRUE
				funcNeedsTokenizing[editFunction] = $$TRUE
				lastEditLine = line
				lastEditPos = pos
				skip = $$TRUE						' xxx add 01/01/94
			END IF
'
'			Merge remaining text
'
			IF entireText THEN
				SWAP endText$[], text$[]
			ELSE
				IFZ endText$[] THEN
					REDIM text$[cursorLine]
					text$[cursorLine] = LEFT$(text$[cursorLine], cursorPos)
				ELSE
					uEndText = UBOUND (endText$[])
					uNewText = cursorLine + uEndText
					REDIM text$[uNewText]
					text$[cursorLine] = LEFT$(text$[cursorLine], cursorPos) + endText$[0]
					IF uEndText THEN
						FOR i = 1 TO uEndText
							ATTACH endText$[i] TO text$[cursorLine + i]
						NEXT i
					END IF
				END IF
			END IF
			IFZ reps THEN GOTO replaceText
		CASE ELSE
			IFZ cursorLine THEN											' already tested entire text
				IFZ cursorPos THEN EXIT SELECT
			END IF
'
'			Create beg half array
'
			uText = UBOUND(text$[])
			IF ((cursorLine = uText) AND (cursorPos >= LEN(text$[uText]))) THEN
				entireText = $$TRUE
				SWAP text$[], begText$[]
			ELSE
				entireText = $$FALSE
				DIM begText$[cursorLine]
				IF cursorLine THEN
					FOR i = 0 TO cursorLine - 1
						ATTACH text$[i] TO begText$[i]
					NEXT i
				END IF
				begText$[cursorLine] = LEFT$(text$[cursorLine], cursorPos)
			END IF
			line = 0
			pos = 0
			startReps = reps
			ReplaceArray (mode, @begText$[], @findText$, @replaceText$, @line, @pos, @reps, skip)
			IF (reps < startReps) THEN
				lastFunctionFound = editFunction
				editFunctionChanged = $$TRUE
				funcAltered[editFunction] = $$TRUE
				funcNeedsTokenizing[editFunction] = $$TRUE
				lastEditLine = line
				lastEditPos = pos
				skip = $$TRUE								' xxx add 01/01/94
			END IF
'
'			Merge remaining text
'
			IF entireText THEN
				SWAP begText$[], text$[]
			ELSE
				IFZ begText$[] THEN
					uNewText = uText - cursorLine
					DIM begText$[uNewText]
					uBegText = 0
				ELSE
					uBegText = UBOUND (begText$[])
					uNewText = uBegText + (uText - cursorLine)
					REDIM begText$[uNewText]
				END IF
				begText$[uBegText] = begText$[uBegText] + MID$(text$[cursorLine], cursorPos + 1)
				IF (uText > cursorLine) THEN
					begText = uBegText + 1
					FOR i = cursorLine + 1 TO uText
						ATTACH text$[i] TO begText$[begText]
						INC begText
					NEXT i
				END IF
				SWAP begText$[], text$[]
			END IF
			IFZ reps THEN GOTO replaceText
	END SELECT
	IF (reps = findReps) THEN GOTO noMatch
	GOTO replaceText
'
'
'
replaceProg:																							' funcNumber has been changed
	IFZ TextHasNonWhites ($$TextArray, @progText$[]) THEN		' fix empty
		DefaultFunctionText (funcNumber, @progText$[])
		line = 0
		pos = 0
	END IF
	freeze = $$TRUE
	bogusFunction = TextToTokenArray (@progText$[], @func[], funcNumber, freeze)
	ATTACH prog[funcNumber,] TO temp[]			' Waste old array
	DIM temp[]
	ATTACH func[] TO prog[funcNumber,]
	funcAltered[funcNumber] = $$TRUE
	funcNeedsTokenizing[funcNumber] = $$FALSE
	IFZ funcNumber THEN prologAltered = $$TRUE
	IF bogusFunction THEN INC renameAttempts					' rename attempt squashed
'
'
'
replaceText:
	IF (lastFunctionFound = editFunction) THEN
		XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		XuiSendMessage (xitGrid, #SetTextCursor, pos, line, 0, topLine, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
		funcCursorPosition[editFunction, 0] = cursorLine
		funcCursorPosition[editFunction, 1] = cursorPos
		funcCursorPosition[editFunction, 2] = topLine
		funcCursorPosition[editFunction, 3] = topIndent
		funcCursorPosition[editFunction, 4] = xCursor
		funcCursorPosition[editFunction, 5] = yCursor
	ELSE
		IFZ editFunctionChanged THEN						' handle editFunction before moving on
			XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			XuiSendMessage (xitGrid, #SetTextCursor, pos, line, 0, 0, $$xitTextLower, 0)
		ELSE
			IFZ TextHasNonWhites($$TextArray, @text$[]) THEN
				DefaultFunctionText (editFunction, @text$[])
			END IF
			XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			XuiSendMessage (xitGrid, #SetTextCursor, pos, line, 0, 0, $$xitTextLower, 0)
			XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
			XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
			XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
			funcCursorPosition[editFunction, 0] = cursorLine
			funcCursorPosition[editFunction, 1] = cursorPos
			funcCursorPosition[editFunction, 2] = topLine
			funcCursorPosition[editFunction, 3] = topIndent
			funcCursorPosition[editFunction, 4] = xCursor
			funcCursorPosition[editFunction, 5] = yCursor
			IFZ editFunction THEN prologAltered = $$TRUE
			line = cursorLine
			pos = cursorPos
		END IF
		funcCursorPosition[lastFunctionFound, 0] = line
		funcCursorPosition[lastFunctionFound, 1] = pos
		funcCursorPosition[lastFunctionFound, 2] = -1
		funcCursorPosition[lastFunctionFound, 3] = -1
		funcCursorPosition[lastFunctionFound, 4] = -1
		funcCursorPosition[lastFunctionFound, 5] = -1
		Display (lastFunctionFound, -1, -1, -1, -1)
	END IF
'
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
'
	IFZ textAlteredSinceLastSave THEN
		textAlteredSinceLastSave = $$TRUE
		UpdateFileFuncLabels ($$TRUE, 0)						' reset file name
	END IF
'
	IF (fileType = $$Program) THEN
		IFZ programAltered THEN
			programAltered = $$TRUE
			AddDispatch (&ResetDataDisplays(), $$ResetAssembly)
		END IF
	END IF
'
	IF renameAttempts THEN
		m0$ = "ReplaceSearch() : replace cannot rename functions : ("
		IF (renameAttempts = 1) THEN
			m0$ = m0$ + "1 voided attempt)"
		ELSE
			m0$ = m0$ + STRING$(renameAttempts) + " voided attempts)"
		END IF
		IF prologAltered THEN
			m0$ = m0$ + "\n\n !!! function names in PROLOG may have been altered !!! "
		END IF
		Message (@m0$)
	END IF
'	SetCursor (entryCursor)
	freezeState = $$FALSE
	RETURN
'
'
'
noMatch:
	IF text$[]
		XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		XuiSendMessage (xitGrid, #SetTextCursor, pos, line, 0, topLine, $$xitTextLower, 0)
	END IF
	IF softInterrupt THEN
		Message (" ReplaceSearch() \n\n interrupted")
	ELSE
		backText$ = XstBinStringToBackStringNL$ (@findText$)
		Message (" ReplaceSearch() \n\n no match found for \n\n '" + backText$ + "' ")
	END IF
'	SetCursor (entryCursor)
	freezeState = $$FALSE
	RETURN
END FUNCTION
'
'
' #########################
' #####  EditRead ()  #####
' #########################
'
'	Read a disk file and put its contents into clipboard
'
FUNCTION  EditRead (skipUpdate)
	SHARED  readBox,  readFilename$,  defaultDirectory$
	SHARED  xitGrid,  xitTextLower,  xitWindow
	UBYTE  null[]
'
	XuiSendMessage (readBox, #GetTextString, 0, 0, 0, 0, 0, @file$)
	lenName = LEN (file$)
	XuiSendMessage (readBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (readBox, #SetTextCursor, lenName, 0, 0, 0, $$FileTextLine, 0)
'
	XstGuessFilename (@readFilename$, @file$, @fileName$, @attributes)
	IF (attributes AND $$FileDirectory) THEN skipUpdate = $$FALSE
	IFZ attributes THEN skipUpdate = $$FALSE
'
	IF skipUpdate THEN
		XstGetFileAttributes (@fileName$, @attributes)
		IFZ attributes THEN skipUpdate = $$FALSE
	END IF
'
	length = LEN(fileName$)
	XuiSendMessage (readBox, #SetTextString, 0, 0, 0, 0, 0, @fileName$)
	XuiSendMessage (readBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (readBox, #SetTextCursor, length, 0, 0, 0, $$FileTextLine, 0)
'
	IFZ skipUpdate THEN
		XuiSendMessage (readBox, #Update, 0, 0, 0, 0, 0, 0)
		XuiSendMessage (readBox, #SetKeyboardFocus, 0, 0, 0, 0, $$FileTextLine, 0)
		XuiSendMessage (readBox, #GetModalInfo, @v0, 0, 0, 0, 0, 0)
'
		SELECT CASE v0
			CASE -1			:	RETURN									' KeyEscape or Cancel
			CASE 2,6,7	:	' text/file, OK button
			CASE ELSE		:	PRINT "EditRead() : unknown response ="; v0
										RETURN
		END SELECT
		XuiSendMessage (readBox, #GetTextString, 0, 0, 0, 0, 0, @fileName$)
	END IF
'
	IFZ fileName$ THEN
		Message (" EditRead() \n\n no file name specified ")
		RETURN
	END IF
'
	XstGetFileAttributes (@fileName$, @attributes)
	SELECT CASE TRUE
		CASE (attributes = 0)
					Message (" EditRead() \n\n cannot find file \n\n " + fileName$ + " ")
					RETURN
		CASE (attributes AND $$FileDirectory)
					Message (" EditRead() \n\n invalid file type \n\n " + fileName$ + " ")
					RETURN
	END SELECT
'
	DIM null[]
	XstLoadString (@fileName$, @text$)
	XgrSetClipboard (0, $$ClipboardTypeText, @text$, @null[])
END FUNCTION
'
'
' ##########################
' #####  EditWrite ()  #####
' ##########################
'
'	Write the contents of the interapplication clipboard into a disk file.
'
FUNCTION  EditWrite (skipUpdate)
	SHARED  writeBox,  writeFilename$,  defaultDirectory$
	SHARED  xitCommand,  xitTextLower
	UBYTE  null[]
'
	XuiSendMessage (writeBox, #GetTextString, 0, 0, 0, 0, 0, @file$)
	lenName = LEN (file$)
	XuiSendMessage (writeBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (writeBox, #SetTextCursor, lenName, 0, 0, 0, $$FileTextLine, 0)
'
	XstGuessFilename (@writeFilename$, @file$, @fileName$, @attributes)
	IF (attributes AND $$FileDirectory) THEN skipUpdate = $$FALSE
	IFZ fileName$ THEN skipUpdate = $$FALSE
'
	length = LEN(fileName$)
	XuiSendMessage (writeBox, #SetTextString, 0, 0, 0, 0, 0, @fileName$)
	XuiSendMessage (writeBox, #SetTextCursor, 0, 0, 0, 0, $$FileTextLine, 0)
	XuiSendMessage (writeBox, #SetTextCursor, length, 0, 0, 0, $$FileTextLine, 0)
'
	IFZ skipUpdate THEN
		XuiSendMessage (writeBox, #Update, 0, 0, 0, 0, 0, 0)
		XuiSendMessage (writeBox, #SetKeyboardFocus, 0, 0, 0, 0, $$FileTextLine, 0)
		XuiSendMessage (writeBox, #GetModalInfo, @v0, 0, 0, 0, 0, 0)
'
		SELECT CASE v0
			CASE -1			:	RETURN									' KeyEscape or Cancel
			CASE 2,6,7	:	' text/file, OK button
			CASE ELSE		:	PRINT "EditWrite() : unknown response ="; v0
										RETURN
		END SELECT
		XuiSendMessage (writeBox, #GetTextString, 0, 0, 0, 0, 0, @fileName$)
	END IF
'
	IFZ fileName$ THEN
		Message (" EditWrite() \n\n no file name specified ")
		RETURN
	END IF
'
	XstGetFileAttributes (@fileName$, @attributes)
	SELECT CASE TRUE
		CASE (attributes AND $$FileDirectory)
					Message (" EditWrite() \n\n invalid file type \n\n directory \n\n " + fileName$ + " ")
					RETURN
	END SELECT
'
	DIM null[]
	XgrGetClipboard (0, $$ClipboardTypeText, @text$, @null[])
	XstSaveString (@fileName$, @text$)
END FUNCTION
'
'
' ############################
' #####  EditAbandon ()  #####
' ############################
'
'	Restore text from editFunction tokens.  PROGRAM mode to erase latest edits.
'
'	In:				none
'	Out:			none
'	Return:		none
'
FUNCTION  EditAbandon ()
	SHARED  abandonBox,  editFunction,  fileType
	SHARED  funcBPAltered[],  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  xitGrid
'
	IF (fileType != $$Program) THEN
		Message (" EditAbandon() \n\n no program loaded ")
		RETURN
	END IF
'
	DIM text$[2]
	IFZ funcNeedsTokenizing[editFunction] THEN
		text$[1] = " text has not been altered "
		text$[2] = " ok "
	ELSE
		text$[1] = " abandon latest edits: "
		text$[2] = " abandon "
	END IF
	XuiSendMessage (abandonBox, #SetTextStrings, 0, 0, 0, 0, 0, @text$[])
	XuiSendMessage (abandonBox, #Resize, 0, 0, 0, 0, 0, 0)
	response = 0
	XuiSendMessage (abandonBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
	SELECT CASE response
		CASE 0		:	IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
		CASE 2		:	' OK button
		CASE 3		:	RETURN
		CASE ELSE	:	PRINT "EditAbandon() : unknown response ="; response
								RETURN
	END SELECT
'
	TokenArrayToText (editFunction, @text$[])
	XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
'
	funcCursorPosition[editFunction, 0] = 0					' Reset cursorChar / topChar
	funcCursorPosition[editFunction, 1] = 0
	funcCursorPosition[editFunction, 2] = 0
	funcCursorPosition[editFunction, 3] = 0
	funcCursorPosition[editFunction, 4] = 0
	funcCursorPosition[editFunction, 5] = 0
	funcBPAltered[editFunction] = $$FALSE
	funcNeedsTokenizing[editFunction] = $$FALSE
'
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
END FUNCTION
'
'
' #########################
' #####  ViewFunc ()  #####
' #########################
'
'	set the function list and manage the View Function Box
'
FUNCTION  ViewFunc (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  editFunction
	SHARED  fileType
	SHARED  prog[]
'
	$label		= 1
	$list			= 2
	$text			= 3
	$button0	= 4
	$button1	= 5
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow		' Direct
		CASE #View					: GOSUB View						' Direct
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****  'grid' unused : r1$ = default function name
'
SUB DisplayWindow
	IF (fileType != $$Program) THEN
		Message (" ViewFunction() \n\n no program loaded ")
		RETURN
	END IF
'
	items = SortFunctionNames (@name$[], $$TRUE)								' include PROLOG
	IFZ r1$ THEN XxxFunctionName ($$XGET, @r1$, editFunction)
	viewLine = 0
	FOR i = 0 TO items - 1
		IF (r1$ = name$[i]) THEN
			viewLine = i
			EXIT FOR
		END IF
	NEXT i
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $list, @name$[])
	XuiSendMessage (grid, #SetTextCursor, 0, viewLine, 0, 0, $list, 0)
	XuiSendToKid (grid, #DisplayWindow, 0, 0, 0, 0, 1, 0)
END SUB
'
'
' *****  Selection  *****  r0 = 2345 = List/Text/Button01
'
SUB Selection
	SELECT CASE r0
		CASE $list
					IF (v0 < 0) THEN
						XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
						EXIT SUB
					END IF
					GOSUB ViewListFunction
		CASE $text
					IF (v0{$$VirtualKey} = $$KeyEscape) THEN
						XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
						EXIT SUB
					END IF
					GOSUB ViewListFunction
		CASE $button0
					GOSUB ViewListFunction
		CASE $button1
					XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
	END SELECT
END SUB
'
' *****  View  *****
'
SUB View
	func$ = r1$
	GOSUB ViewFunction
END SUB
'
' *****  ViewListFunction  *****
'
SUB ViewListFunction
	XuiSendMessage (grid, #GrabTextArray, 0, 0, 0, 0, $list, @name$[])
	XuiSendMessage (grid, #GetTextCursor, @viewPos, @viewLine, @topPos, @topLine, $list, 0)
	IF ((viewLine < 0) OR (viewLine > UBOUND(name$[]))) THEN
		XuiSendMessage (grid, #PokeTextArray, 0, 0, 0, 0, $list, @name$[])
		Message (" ViewFunction() \n\n no function selected ")
		RETURN
	END IF
	func$ = name$[viewLine]
	XuiSendMessage (grid, #PokeTextArray, 0, 0, 0, 0, $list, @name$[])
	GOSUB ViewFunction
	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  ViewFunction  *****  func$
'
SUB ViewFunction
	XxxPassFunctionArrays ($$XGET, @funcSymbol$[], @funcToken[], @funcScope[])
'
'	Look for exact match
'
	funcNumber = editFunction + 1				' start looking forward
	endFunction = maxFuncNumber
	segment = 0
	DO UNTIL (segment > 1)
		DO UNTIL (funcNumber > endFunction)
			IF prog[funcNumber,] THEN
				IFZ funcNumber THEN
					funcName$ = "PROLOG"				' funcSymbol$[0] = "SYSTEMCALL"
				ELSE
					funcName$ = funcSymbol$[funcNumber]
				END IF
				IF (func$ = funcName$) THEN
					XxxPassFunctionArrays ($$XSET, @funcSymbol$[], @funcToken[], @funcScope[])
					Display (funcNumber, -1, -1, -1, -1)
					RETURN
				END IF
			END IF
			INC funcNumber
		LOOP
		funcNumber = 0
		endFunction = editFunction				' finish with front segment
		INC segment
	LOOP
'
'	Look for closest match
'
	lenFunc = LEN(func$)
	funcNumber = editFunction + 1				' start looking forward
	endFunction = maxFuncNumber
	segment = 0
	DO UNTIL (segment > 1)
		DO UNTIL (funcNumber > endFunction)
			IF prog[funcNumber,] THEN
				IFZ funcNumber THEN
					funcName$ = "PROLOG"				' funcSymbol$[0] = "SYSTEMCALL"
				ELSE
					funcName$ = funcSymbol$[funcNumber]
				END IF
'				test$ = LEFT$(funcName$, lenFunc)
'				IF (func$ = test$) THEN
				IF (func$ = LEFT$(funcName$, lenFunc)) THEN
					XxxPassFunctionArrays ($$XSET, @funcSymbol$[], @funcToken[], @funcScope[])
					Display (funcNumber, -1, -1, -1, -1)
					RETURN
				END IF
			END IF
			INC funcNumber
		LOOP
		funcNumber = 0
		endFunction = editFunction				' finish with front segment
		INC segment
	LOOP
	XxxPassFunctionArrays ($$XSET, @funcSymbol$[], @funcToken[], @funcScope[])
	Message (" ViewFunction() \n\n no function name match for \n\n \"" + func$ + "\" ")
END SUB
END FUNCTION
'
'
' ##############################
' #####  ViewPriorFunc ()  #####
' ##############################
'
'	Display the prior function viewed
'
'	In:				none
'	Out:			none
'	Return:		none
'
FUNCTION  ViewPriorFunc ()
	SHARED  priorFunction,  fileType
'
	IF (fileType != $$Program) THEN
		Message (" ViewPriorFunction() \n\n no program loaded ")
		RETURN
	END IF
'
	Display (priorFunction, -1, -1, -1, -1)
END FUNCTION
'
'
' ############################
' #####  ViewNewFunc ()  #####
' ############################
'
'	Create and view a new function with name from View New Function box
'
'	Keeps current DECLARE in PROLOG if one exists.
'	Leaves duplicate declarations in PROLOG.
'
FUNCTION  ViewNewFunc (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  uprog,  editFunction,  priorFunction
	SHARED  environmentActive
	SHARED  viewNewBox,  xitGrid,  fileType
	SHARED  programAltered
'
	$label		= 1
	$textline	= 2
	$button0	= 3
	$button1	= 4
'
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow
	END SELECT
	RETURN
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
' *****  DisplayWindow  *****  'grid' unused : r1$ = default function name
'
SUB DisplayWindow
	IF (fileType != $$Program) THEN
		Message (" ViewNewFunction() \n\n no program loaded ")
		RETURN
	END IF

	XuiSendToKid (grid, #DisplayWindow, 0, 0, 0, 0, 1, 0)
END SUB
'
' *****  Selection  *****
'
SUB Selection
	SELECT CASE r0
		CASE $textline
			IF (v0{$$VirtualKey} = $$KeyEscape) THEN
				XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
				EXIT SUB
			END IF
			GOSUB NewFunction
		CASE $button0
			GOSUB NewFunction
	END SELECT

	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
END SUB
'
' ***** NewFunction *****
'
SUB NewFunction
'
	IF (fileType != $$Program) THEN
		Message (" ViewNewFunction() \n\n no program loaded ")
		RETURN
	END IF
'
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		IF environmentActive THEN
			message$ = "??? terminate program execution ???"
			warningResponse = WarningResponse (@message$, @" new ", @"")
			IF (warningResponse = $$WarningCancel) THEN RETURN
		END IF
		XxxSetBlowback ()
		AddDispatch (&ViewNewFunc(), 0)
		RETURN
	END IF
'
	XuiSendMessage (viewNewBox, #GetTextString, 0, 0, 0, 0, $$DialogText, @func$)
	XuiSendMessage (viewNewBox, #SetTextString, 0, 0, 0, 0, $$DialogText, "")
	func$ = TRIM$(func$)
'
	IFZ func$ THEN
		Message (" NewFunction() \n\n received empty function name ")
		RETURN
	END IF
'
	cchar = func${0}
	IF ((cchar >= '0') AND (cchar <= '9')) THEN
		Message (" NewFunction() \n\n function name cannot begin with digit ")
		RETURN
	END IF
'
	lastChar = UBOUND(func$)
	FOR i = 0 TO lastChar
		cchar = func${i}
		IF ((cchar >= 'a') AND (cchar <= 'z')) THEN DO NEXT
		IF ((cchar >= 'A') AND (cchar <= 'Z')) THEN DO NEXT
		IF ((cchar >= '0') AND (cchar <= '9')) THEN DO NEXT
		IF (cchar = '_') THEN DO NEXT
		IF (cchar = '$') THEN									' only explicit type is STRING
			IF (i = lastChar) THEN EXIT FOR
		END IF
		Message (" NewFunction() \n\n function name contains invalid character ")
		RETURN
	NEXT i
'
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
'
	IF (func$ == "PROLOG") THEN
		Display (0, 0, 0, 0, 0)								' wise guy
		RETURN
	END IF
'
	token$ = func$ + " ("											' compiler assigns function number
	XxxParseSourceLine (@token$, @tok[])
'
'	IFZ tok[] THEN RETURN
'
	IF (maxFuncNumber > uprog) THEN
		uprog = maxFuncNumber + (maxFuncNumber >> 2)
		REDIM prog[uprog,]
		REDIM funcAltered[uprog]
		REDIM funcBPAltered[uprog]
		REDIM funcNeedsTokenizing[uprog]
		REDIM funcCursorPosition[uprog, 5]
	END IF
	funcNumber = tok[1]{$$NUMBER}
'
	IF prog[funcNumber,] THEN
		Display (funcNumber, 0, 0, 0, 0)			' already exists; show it to user
		RETURN
	END IF
'
	redisplay = $$FALSE
	reportBogusRename = $$TRUE
	RestoreTextToProg (redisplay, reportBogusRename)
'
	XitGetDECLARE (@func$, @declare$)
	IFZ declare$ THEN
		declare$ = "DECLARE FUNCTION  " + func$ + " ()"
		XitSetDECLARE (@func$, @declare$)
	END IF
'
' add new function
'
	funcAltered[funcNumber] = $$TRUE
	funcBPAltered[funcNumber] = $$FALSE
	funcNeedsTokenizing[funcNumber] = $$FALSE
'
	funcCursorPosition[funcNumber, 0]	= 0				' zero cursorChar / topChar
	funcCursorPosition[funcNumber, 1]	= 0
	funcCursorPosition[funcNumber, 2]	= 0
	funcCursorPosition[funcNumber, 3]	= 0
	funcCursorPosition[funcNumber, 4]	= 0
	funcCursorPosition[funcNumber, 5]	= 0
'
	programAltered = $$TRUE
	DefaultFunctionText (funcNumber, @text$[])
	freeze = $$FALSE
	TextToTokenArray (@text$[], @func[], funcNumber, freeze)
	ATTACH func[] TO prog[funcNumber,]
	priorFunction = editFunction
	editFunction = funcNumber
	XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
'
	UpdateFileFuncLabels (0, $$TRUE)							' reset function name
	ResetDataDisplays ($$ResetAssembly)
END SUB
END FUNCTION
'
'
' ###############################
' #####  ViewDeleteFunc ()  #####
' ###############################
'
'	Set the function list and manage the ViewDeleteFunction Box
'
'	Discussion:
'		Delete removes defined functions (ie user functions that have code defined
'			as opposed to functions merely DECLAREd or used).  It removes the code
'			as well as it's corresponding DECLARE in the PROLOG.
'		The compiler does NOT remove the function number or symbol from its arrays--
'			it will reside there until another PASS 0 tokenization.
'
FUNCTION  ViewDeleteFunc (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  editFunction,  fileType
	SHARED  programAltered,  textAlteredSinceLastSave
	SHARED  xitGrid
'
	$label		= 1
	$list			= 2
	$text			= 3
	$button0	= 4
	$button1	= 5
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****  'grid' unused : r1$ = default function name
'
SUB DisplayWindow
	IF (fileType != $$Program) THEN
		Message (" ViewDeleteFunction() \n\n no program loaded ")
		RETURN
	END IF

	items = SortFunctionNames (@name$[], $$FALSE)				' don't include PROLOG
	IFZ items THEN
		Message (" ViewDeleteFunction() \n\n no functions to delete ")
		RETURN
	END IF

	XxxFunctionName ($$XGET, @editFunction$, editFunction)
	IFZ r1$ THEN r1$ = editFunction$
	viewLine = -1
	FOR i = 0 TO items - 1
		IF (r1$ = name$[i]) THEN
			viewLine = i
			EXIT FOR
		END IF
	NEXT i
'
'	If no identical match, select match of first n chars
'
	IF (viewLine < 0) THEN
		lenR1 = LEN(r1$)
		IF lenR1 THEN
			IF (r1$ = LEFT$(editFunction$, lenR1)) THEN
				FOR i = 0 TO items - 1
					IF (editFunction$ = name$[i]) THEN
						viewLine = i
						EXIT FOR
					END IF
				NEXT i
			ELSE
				FOR i = 0 TO items - 1
					IF (r1$ = LEFT$(name$[i], lenR1)) THEN
						viewLine = i
						EXIT FOR
					END IF
				NEXT i
			END IF
		END IF
	END IF
	IF (viewLine < 0) THEN viewLine = 0
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $list, @name$[])
	XuiSendMessage (grid, #SetTextCursor, 0, viewLine, 0, 0, $list, 0)
	XuiSendToKid (grid, #DisplayWindow, 0, 0, 0, 0, 1, 0)
END SUB
'
'
' *****  Selection  *****
'
SUB Selection
	SELECT CASE r0
		CASE $list
			IF (v0 < 0) THEN
				XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
				EXIT SUB
			END IF
			GOSUB DeleteFunction
		CASE $text
			IF (v0{$$VirtualKey} = $$KeyEscape) THEN
				XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
				EXIT SUB
			END IF
			XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
			GOSUB DeleteFunction
		CASE $button0
			XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
			GOSUB DeleteFunction
		CASE $button1
			XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
	END SELECT
END SUB
'
'
' *****  DeleteFunction  *****
'
SUB DeleteFunction
	IF (fileType != $$Program) THEN
		Message (" ViewDeleteFunction() \n\n no program ")
		RETURN
	END IF
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		message$ = "ViewDeleteFunction()\ncannot delete function while program executes"
		warningResponse = WarningResponse (@message$, @" TERMINATE ", "")
		IF (warningResponse = $$WarningCancel) THEN EXIT SUB
		XxxSetBlowback ()
		RETURN
	END IF
	XuiSendMessage (grid, #GrabTextArray, 0, 0, 0, 0, $list, @name$[])
	XuiSendMessage (grid, #GetTextCursor, @viewPos, @viewLine, @viewTopPos, @viewTopLine, $list, 0)
	IF ((viewLine < 0) OR (viewLine > UBOUND(name$[]))) THEN
		XuiSendMessage (grid, #PokeTextArray, 0, 0, 0, 0, $list, @name$[])
		Message (" ViewDeleteFunction() \n\n no function selected ")
		RETURN
	END IF
	funcName$ = name$[viewLine]
	XuiSendMessage (grid, #PokeTextArray, 0, 0, 0, 0, $list, @name$[])
'
	message$ = "ViewDeleteFunction()\nconfirm DELETE function\n" + funcName$ + "()"
	warningResponse = WarningResponse (@message$, @" DELETE ", "")
	IF (warningResponse = $$WarningCancel) THEN RETURN
'
	DIM text$[]																				' delete function
	error = XitSetFunction (@funcName$, @text$[])
	IF error THEN
		SELECT CASE error
			CASE $$XitFunctionUndefined		:	RETURN (0)		' not there
			CASE $$XitIllegalFunctionName	:	error$ = "invalid function name : " + funcName$
			CASE ELSE											:	error$ = "error : not deleted : " + funcName$
		END SELECT
		Message (" ViewDeleteFunction() \n\n " + error$ + " ")
		RETURN
	END IF
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
	XitSetDECLARE (@funcName$, "")
'
'	Remove function name from delete list / redisplay
'
	XuiSendMessage (grid, #GrabTextArray, 0, 0, 0, 0, $list, @name$[])
	uName = UBOUND(name$[])
	IF (viewLine = uName) THEN
		IFZ uName THEN
			DIM name$[]
		ELSE
			REDIM name$[uName - 1]
		END IF
	ELSE
		FOR i = viewLine TO uName - 1
			SWAP name$[i], name$[i + 1]
		NEXT i
		REDIM name$[uName - 1]
	END IF
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $list, @name$[])
	XuiSendMessage (grid, #SetTextCursor, viewPos, viewLine, viewTopPos, viewTopLine, $list, 0)
	XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $list, 0)
'	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
END SUB
END FUNCTION
'
'
' ###############################
' #####  ViewRenameFunc ()  #####
' ###############################
'
'	Rename the editFunction with that specified in the View Rename Function box
'
'	In:				skipUpdate
'	Out:			none
'	Return:		none
'
'	Discussion:
'		NOT ##USERRUNNING
'
'		Not allowed if requested name matches a currently defined function.
'
'		The new function number is NOT the same as the old:  thus, all calls
'			to the original name will still use the original function number and name--
'			the defined code just "moves out from under these calls".
'		This keeps the user's calls and the associated code separate.  (User does
'			a global rename on the old names if he wants to match them up with the
'			new name.)
'		DECLARE for old name/funcNumber is not removed from PROLOG.
'
'
'	BAD TECHNIQUE:
'		Replaces the function name associated with this token.  Thus all program
'			references to this function instantly change to the new.  The function
'			number remains the same.
'
'		Problems with this approach:
'			User is building a program, not all modules defined.
'			He references fred(), but fred() is not written yet.  He references
'			mary(), and mary() is written.  Forgetting that he already was using
'			fred(), he renames function mary() to fred()--instantly merging the
'			two function references.  What a mess!
'
FUNCTION  ViewRenameFunc (skipUpdate)
	EXTERNAL /xxx/  maxFuncNumber,  errorCount
	SHARED  prog[]
	SHARED  funcAltered[],  funcBPAltered[],  funcNeedsTokenizing[]
	SHARED  funcCursorPosition[],  errorFunc[]
	SHARED  environmentActive
	SHARED  uprog,  editFunction,  viewRenameBox,  xitGrid,  fileType
	SHARED  programAltered,  textAlteredSinceLastSave
	SHARED  T_FUNCTION,  T_CFUNCTION,  T_SFUNCTION
	STATIC  GOADDR kinds[]
	AUTO    funcNumber,  line,  j,  newType,  token

	IF (fileType != $$Program) THEN
		Message (" ViewRenameFunction() \n\n no program loaded ")
		RETURN
	END IF

	IFZ editFunction THEN
		Message (" ViewRenameFunction() \n\n can't rename PROLOG ")
		RETURN
	END IF

	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		IF environmentActive THEN
			message$ = "??? terminate program execution ???"
			warningResponse = WarningResponse (@message$, @" new ", @"")
			IF (warningResponse = $$WarningCancel) THEN RETURN
		END IF
		XxxSetBlowback ()
		AddDispatch (&ViewRenameFunc(), 0)
		RETURN
	END IF
'
	IFZ skipUpdate THEN
		XuiSendMessage (viewRenameBox, #SetTextString, 0, 0, 0, 0, $$DialogText, "")
	END IF
	response = 0
	XuiSendMessage (viewRenameBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
	SELECT CASE response
		CASE 2		:	IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
		CASE 3		:	' OK button
		CASE 4		:	RETURN
		CASE ELSE	:	PRINT "ViewRenameFunc() : unknown response ="; response
								RETURN
	END SELECT
	XuiSendMessage (viewRenameBox, #GetTextString, 0, 0, 0, 0, $$DialogText, @func$)
	func$ = TRIM$(func$)
'
	IFZ func$ THEN
		Message (" ViewRenameFunction() \n\n received empty function name ")
		RETURN
	END IF
'
'	Confirm valid function name
'
	cchar = func${0}
	IF ((cchar >= '0') AND (cchar <= '9')) THEN
		Message (" ViewRenameFunction() \n\n function name cannot begin with digit ")
		RETURN
	END IF
	lastChar = UBOUND(func$)
	FOR i = 0 TO lastChar
		cchar = func${i}
		IF ((cchar >= 'a') AND (cchar <= 'z')) THEN DO NEXT
		IF ((cchar >= 'A') AND (cchar <= 'Z')) THEN DO NEXT
		IF ((cchar >= '0') AND (cchar <= '9')) THEN DO NEXT
		IF (cchar = '_') THEN DO NEXT
		IF (cchar = '$') THEN									' only explicit type is STRING
			IF (i = lastChar) THEN EXIT FOR
		END IF
		Message (" ViewRenameFunction() \n\n function name contains invalid character ")
		RETURN
	NEXT i
'
' ****************************
' *****  GOOD TECHNIQUE  *****
' ****************************
'
	token$ = func$ + " ("										' compiler assigns function number
	XxxParseSourceLine (@token$, @tok[])
'	IFZ tok[] THEN RETURN						' big problem
'
	IF (maxFuncNumber > uprog) THEN
		uprog = maxFuncNumber + (maxFuncNumber >> 2)
		REDIM prog[uprog,]
		REDIM funcAltered[uprog]
		REDIM funcBPAltered[uprog]
		REDIM funcNeedsTokenizing[uprog]
		REDIM funcCursorPosition[uprog, 5]
	END IF
	funcNumber = tok[1]{$$NUMBER}
	DIM tok[]

	IF prog[funcNumber,] THEN
		Message (" ViewRenameFunction() \n\n new function name already exists ")
		RETURN
	END IF

	redisplay = $$FALSE								' retokenize text and prepare for rename
	reportBogusRename = $$FALSE
	RestoreTextToProg (redisplay, reportBogusRename)
'
'	Clean out any error codes, change to new funcNumber
'
	ATTACH prog[editFunction,] TO func[]		' removes old number's code
	numLines = UBOUND(func[])
	FOR line = 0 TO numLines
		ATTACH func[line,] TO tok[]
'		IFZ tok[] THEN DO NEXT								' don't blow up if no tokens
		startToken = tok[0]
		IF startToken{$$BYTE1} THEN
			tok[0] = startToken AND 0xFFFF00FF
		END IF
		IFZ changedFunction THEN
			toks = startToken{$$BYTE0}
			IF (toks > 1) THEN
				tokPtr = 1
				NextXitToken(@tok[], @tokPtr, toks, @token1)		' Trimmed, so not blank
				SELECT CASE token1
					CASE  T_FUNCTION, T_CFUNCTION, T_SFUNCTION
						DO UNTIL (tokPtr > toks)
							token = tok[tokPtr]
							IF (token{$$KIND} = $$KIND_FUNCTIONS) THEN
								tok[tokPtr] = (token AND 0xFFFF0000) + funcNumber
								changedFunction = $$TRUE
								EXIT DO
							END IF
							INC tokPtr
						LOOP
				END SELECT
			END IF
		END IF
		ATTACH tok[] TO func[line,]
	NEXT line

	IF errorCount THEN
		FOR i = 1 TO errorCount
			func = errorFunc[i]
			IF (func = editFunction) THEN
				errorFunc[i] = -1
			ELSE
				IF (func != -1) THEN foundError = $$TRUE
			END IF
		NEXT i
		IFZ foundError THEN errorCount = 0
	END IF
'
'	If no DECLARE for new name, add one based on original name
'
	CloneDECLARE (editFunction, funcNumber)
'
'	Waste the old function number's existence from record
'
	funcAltered[editFunction]					= $$FALSE		' clear alteration flags
	funcBPAltered[editFunction]				= $$FALSE
	funcNeedsTokenizing[editFunction]	= $$FALSE
	funcCursorPosition[editFunction, 0]	= 0				' reset cursorChar / topChar
	funcCursorPosition[editFunction, 1]	= 0
	funcCursorPosition[editFunction, 2]	= 0
	funcCursorPosition[editFunction, 3]	= 0
	funcCursorPosition[editFunction, 4]	= 0
	funcCursorPosition[editFunction, 5]	= 0
	XxxDeleteFunction (editFunction)							' tell the compiler
	programAltered = $$TRUE
'
' Display renamed function
'
	editFunction = funcNumber											' move over to the new number
	ATTACH func[] TO prog[editFunction,]					' move the tokens over
	TokenArrayToText (editFunction, @text$[])
	XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
'
	funcCursorPosition[editFunction, 0]	= 0
	funcCursorPosition[editFunction, 1]	= 0
	funcCursorPosition[editFunction, 2]	= 0
	funcCursorPosition[editFunction, 3]	= 0
	funcCursorPosition[editFunction, 4]	= 0
	funcCursorPosition[editFunction, 5]	= 0
	funcAltered[editFunction]					= $$TRUE
	funcBPAltered[editFunction]				= $$FALSE
	funcNeedsTokenizing[editFunction]	= $$FALSE
	textAlteredSinceLastSave = $$TRUE
	UpdateFileFuncLabels ($$TRUE, $$TRUE)				' Reset function name
	ResetDataDisplays ($$ResetAssembly)
	RETURN
END FUNCTION
'
'
' ##############################
' #####  ViewCloneFunc ()  #####
' ##############################
'
'	Clone editFunction to name specified in View Clone Function box
'
'	In:				skipUpdate
'	Out:			none
'	Return:		none
'
'	Discussion:
'		If ##USERRUNNING, ignore rename.  (A blowback would be required--blowback
'			displays the function currently being executed--don't want to rename
'			THAT one.)
'
'		Uses currently existing DECLARE from PROLOG (if it exists) as pattern for
'			cloned function's DECLARE in PROLOG; doesn't remove duplicates from PROLOG
'
FUNCTION  ViewCloneFunc (skipUpdate)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  uprog,  editFunction,  priorFunction,  viewCloneBox
	SHARED  fileType,  programAltered
	SHARED  textAlteredSinceLastSave,  xitGrid
'
	IF (fileType != $$Program) THEN
		Message (" ViewCloneFunction() \n\n no program loaded ")
		RETURN
	END IF
'
	IFZ editFunction THEN
		Message (" ViewCloneFunction() \n\n can't clone PROLOG ")
		RETURN
	END IF
'
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		IF environmentActive THEN
			message$ = "??? terminate program execution ???"
			warningResponse = WarningResponse (@message$, @" CLONE ", "")
			IF (warningResponse = $$WarningCancel) THEN RETURN
		END IF
		XxxSetBlowback ()
		AddDispatch (&ViewCloneFunc(), 0)
		RETURN
	END IF
'
	IFZ skipUpdate THEN
		XuiSendMessage (viewCloneBox, #SetTextString, 0, 0, 0, 0, $$DialogText, "")
	END IF
	response = 0
	XuiSendMessage (viewCloneBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
	SELECT CASE response
		CASE 2:			IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
		CASE 3:			' OK button
		CASE 4:			RETURN
		CASE ELSE:	PRINT "ViewCloneFunc() : unknown response ="; response
								RETURN
	END SELECT
'
	XuiSendMessage (viewCloneBox, #GetTextString, 0, 0, 0, 0, $$DialogText, @func$)
	func$ = TRIM$(func$)
'
	IFZ func$ THEN
		Message (" ViewCloneFunction() \n\n received empty function name ")
		RETURN
	END IF
'
	cchar = func${0}
	IF ((cchar >= '0') AND (cchar <= '9')) THEN
		Message (" ViewCloneFunction() \n\n function name cannot begin with digit ")
		RETURN
	END IF
	lastChar = UBOUND(func$)
	FOR i = 0 TO lastChar
		cchar = func${i}
		IF ((cchar >= 'a') AND (cchar <= 'z')) THEN DO NEXT
		IF ((cchar >= 'A') AND (cchar <= 'Z')) THEN DO NEXT
		IF ((cchar >= '0') AND (cchar <= '9')) THEN DO NEXT
		IF (cchar = '_') THEN DO NEXT
		IF (cchar = '$') THEN									' only explicit type is STRING
			IF (i = lastChar) THEN EXIT FOR
		END IF
		Message (" ViewCloneFunction() \n\n function name contains invalid character ")
		RETURN
	NEXT i
'
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
'
	IF (func$ = "PROLOG") THEN
		Message (" ViewCloneFunction() \n\n can't clone PROLOG ")
		RETURN
	END IF

	token$ = func$ + " ("									' compiler assigns function number
	XxxParseSourceLine (@token$, @tok[])
'	IFZ tok[] THEN RETURN									' avert array disaster
	IF (maxFuncNumber > uprog) THEN
		uprog = maxFuncNumber + (maxFuncNumber >> 2)
		REDIM prog[uprog,]
		REDIM funcAltered[uprog]
		REDIM funcBPAltered[uprog]
		REDIM funcNeedsTokenizing[uprog]
		REDIM funcCursorPosition[uprog, 5]
	END IF
	funcNumber = tok[1]{$$NUMBER}

	IF prog[funcNumber,] THEN
		Message (" ViewCloneFunction() \n\n new function name already exists ")
		RETURN
	END IF

	redisplay = $$FALSE
	reportBogusRename = $$TRUE
	RestoreTextToProg(redisplay, reportBogusRename)
'
'	If no DECLARE for new name, add one based on original name
'
	CloneDECLARE (editFunction, funcNumber)

'	Tokenize the current text for the new function
	priorFunction = editFunction
	editFunction = funcNumber
	XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	freeze = $$TRUE
	bogusFunction = TextToTokenArray (@text$[], @func[], editFunction, freeze)
'
'	Clean out error codes, if any
'
	numLines = UBOUND(func[])
	FOR line = 0 TO numLines
		startToken = func[line,0]
		IF startToken{$$BYTE1} THEN
			func[line,0] = startToken AND 0xFFFF00FF
		END IF
	NEXT line
	ATTACH prog[editFunction,] TO temp[]      ' out with the old...
	ATTACH func[] TO prog[editFunction,]      '   ...in with the new
'
' Display clone function
'
	TokenArrayToText (editFunction, @text$[])
	XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)

	funcCursorPosition[editFunction, 0] = 0
	funcCursorPosition[editFunction, 1] = 0
	funcCursorPosition[editFunction, 2] = 0
	funcCursorPosition[editFunction, 3] = 0
	funcCursorPosition[editFunction, 4] = 0
	funcCursorPosition[editFunction, 5] = 0
	funcBPAltered[editFunction]					= $$FALSE
	funcNeedsTokenizing[editFunction]		= $$FALSE
	funcAltered[editFunction]						= $$TRUE
	programAltered											= $$TRUE

	textAlteredSinceLastSave = $$TRUE
	UpdateFileFuncLabels ($$TRUE, $$TRUE)				' Reset function name
	ResetDataDisplays ($$ResetAssembly)
END FUNCTION
'
'
' #############################
' #####  ViewLoadFunc ()  #####
' #############################
'
FUNCTION  ViewLoadFunc (skipUpdate)
	SHARED  editFunction,  viewLoadBox
	SHARED  fileType,  xitGrid
'
	IF (fileType != $$Program) THEN
		Message (" ViewLoadFunction() \n\n no program loaded ")
		RETURN
	END IF
'
	IFZ skipUpdate THEN
		XuiSendMessage (viewLoadBox, #SetTextString, 0, 0, 0, 0, 2, "")
		XuiSendMessage (viewLoadBox, #SetTextString, 0, 0, 0, 0, 4, "")
	END IF
	response = 0
	XuiSendMessage (viewLoadBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
	SELECT CASE response
		CASE 2,4	:	IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
		CASE 5		:	' OK button
		CASE 6		:	RETURN
		CASE ELSE	:	PRINT "ViewLoadFunc() : unknown response ="; response
								RETURN
	END SELECT
	XuiSendMessage (viewLoadBox, #GetTextString, 0, 0, 0, 0, 2, @funcName$)
	XuiSendMessage (viewLoadBox, #GetTextString, 0, 0, 0, 0, 4, @fileName$)
	funcName$ = TRIM$(funcName$)
	fileName$ = TRIM$(fileName$)
	IFZ funcName$ THEN
		Message (" ViewLoadFunction() \n\n received empty function name ")
		RETURN
	END IF
	IFZ fileName$ THEN
		Message (" ViewLoadFunction() \n\n received empty file name ")
		RETURN
	END IF
	error = XitLoadFunction (@funcName$, @fileName$)
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
	IF error THEN
		SELECT CASE error
			CASE $$XitIllegalFunctionName
				Message (" ViewLoadFunction() \n\n function not loaded \n\n bad function name \n\n" + funcName$)
			CASE ELSE
				Message (" ViewLoadFunction() \n\n function not loaded \n\n bad file name \n\n" + fileName$)
		END SELECT
	ELSE
		XitSetDisplayedFunction (@funcName$)
	END IF
END FUNCTION
'
'
' #############################
' #####  ViewSaveFunc ()  #####
' #############################
'
FUNCTION  ViewSaveFunc (skipUpdate)
	SHARED  editFunction,  viewSaveBox
	SHARED  fileType,  xitGrid
'
	IF (fileType != $$Program) THEN
		Message (" ViewSaveFunction() \n\n no program loaded ")
		RETURN
	END IF
	IFZ skipUpdate THEN
		XuiSendMessage (viewSaveBox, #SetTextString, 0, 0, 0, 0, 2, "")
		XuiSendMessage (viewSaveBox, #SetTextString, 0, 0, 0, 0, 4, "")
	END IF
	response = 0
	XuiSendMessage (viewSaveBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
	SELECT CASE response
		CASE 2,4	:	IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
		CASE 5		:	' OK button
		CASE 6		:	RETURN
		CASE ELSE	:	PRINT "ViewSaveFunc() : unknown response ="; response
								RETURN
	END SELECT
	XuiSendMessage (viewSaveBox, #GetTextString, 0, 0, 0, 0, 2, @funcName$)
	XuiSendMessage (viewSaveBox, #GetTextString, 0, 0, 0, 0, 4, @fileName$)
	funcName$ = TRIM$(funcName$)
	fileName$ = TRIM$(fileName$)
	IFZ funcName$ THEN
		Message (" ViewSaveFunction() \n\n received empty function name ")
		RETURN
	END IF
'
	IFZ fileName$ THEN
		Message (" ViewSaveFunction() \n\n received empty file name ")
		RETURN
	END IF
'
	XstGetFileAttributes (@fileName$, @attributes)
	IF (attributes AND $$FileDirectory) THEN
		Message (" ViewSaveFunction() \n\n file not saved \n\n file name is a directory \n\n " + fileName$ + " ")
		RETURN
	END IF
'
	IF attributes THEN
		message$ = "ViewSaveFunction()\nfilename already exists\n" + fileName$
		warningResponse = WarningResponse (@message$, @" save ", "")
		IF (warningResponse = $$WarningCancel) THEN RETURN
		XstDeleteFile (fileName$)
	END IF
'
	error = XitSaveFunction (@funcName$, @fileName$)
	IF error THEN
		SELECT CASE error
			CASE $$XitIllegalFunctionName
				Message (" ViewSaveFunction() \n\n function not saved \n\n invalid function name \n\n " + funcName$ + " ")
			CASE ELSE
				Message (" ViewSaveFunction() \n\n function not saved \n\n invalid file name \n\n " + fileName$ + " ")
		END SELECT
	END IF
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
END FUNCTION
'
'
' ################################
' #####  ViewMergePROLOG ()  #####
' ################################
'
'	Merge file into PROLOG
'
FUNCTION  ViewMergePROLOG (skipUpdate)
	SHARED  editFunction,  viewMergeBox
	SHARED  fileType,  xitGrid
'
	IF (fileType != $$Program) THEN
		Message (" ViewMergePROLOG() \n\n no program loaded ")
		RETURN
	END IF
'
	IFZ skipUpdate THEN
		XuiSendMessage (viewMergeBox, #SetTextString, 0, 0, 0, 0, $$DialogText, "")
	END IF
	response = 0
	XuiSendMessage (viewMergeBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
	SELECT CASE response
		CASE 2		:	IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
		CASE 3		:	' OK button
		CASE 4		:	RETURN
		CASE ELSE	:	PRINT "ViewMergePROLOG() : unknown response ="; response
								RETURN
	END SELECT
	XuiSendMessage (viewMergeBox, #GetTextString, 0, 0, 0, 0, $$DialogText, @fileName$)
	fileName$ = TRIM$(fileName$)
	IFZ fileName$ THEN
		Message (" ViewMergePROLOG() \n\n received empty file name ")
		RETURN
	END IF
	error = XitMergePROLOG (@fileName$)
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
	IF error THEN
		Message (" ViewMergePROLOG() \n\n *** not merged *** \n\n bad file name \n\n " + fileName$ + " ")
	ELSE
		XitSetDisplayedFunction (@"PROLOG")
	END IF
END FUNCTION
'
'
' ##############################################
' #####  ViewImportFunctionFromProgram ()  #####
' ##############################################
'
' import a function from a *.x file
' function ViewImportFunctionFromProgram is sensitive to exact
' number of spaces between keywords
' eg, in PROLOG :
'		DECLARE FUNCTION  Tally (SearchMe$, SearchFor$)
' and as shown in program:
'		FUNCTION  Tally (SearchMe$, SearchFor$)
' note that there are 2 spaces between FUNCTION and function name or type declaration
' there is also 1 space between function name and argument list ( ).
'
FUNCTION  ViewImportFunctionFromProgram (skipUpdate)
	SHARED  editFunction,  viewImportBox
	SHARED  fileType,  xitGrid
'
	IF (fileType != $$Program) THEN
		Message (" ViewImportFunctionFromProgram() \n\n no program loaded ")
		RETURN
	END IF
'
	IFZ skipUpdate THEN
		XuiSendMessage (viewImportBox, #SetTextString, 0, 0, 0, 0, 2, "")
		XuiSendMessage (viewImportBox, #SetTextString, 0, 0, 0, 0, 4, "")
	END IF
	response = 0
	XuiSendMessage (viewImportBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
	SELECT CASE response
		CASE 2,4	:	IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
		CASE 5		:	' OK button
		CASE 6		:	RETURN
		CASE ELSE	:	PRINT "ViewImportFunctionFromProgram() : unknown response ="; response
								RETURN
	END SELECT
	XuiSendMessage (viewImportBox, #GetTextString, 0, 0, 0, 0, 2, @funcName$)
	XuiSendMessage (viewImportBox, #GetTextString, 0, 0, 0, 0, 4, @fileName$)
	funcName$ = TRIM$(funcName$)
	fileName$ = TRIM$(fileName$)
	IFZ funcName$ THEN
		Message (" ViewImportFunctionFromProgram() \n\n received empty function name ")
		RETURN
	END IF
	IFZ fileName$ THEN
		Message (" ViewImportFunctionFromProgram() \n\n received empty file name ")
		RETURN
	END IF
'
	fn$ = LCASE$(fileName$)
	IF RIGHT$(fn$, 2) <> ".x" THEN
		Message (" ViewImportFunctionFromProgram() \n\n function not loaded \n\n not *.x name \n\n" + fileName$)
		RETURN
	END IF
'
	error = XstLoadStringArray (@fileName$, @text$[])
	IF error THEN
		Message (" ViewImportFunctionFromProgram() \n\n function not loaded \n\n bad file name \n\n" + fileName$)
		RETURN
	END IF
'
	IFZ text$[] THEN
		Message (" ViewImportFunctionFromProgram() \n\n function not loaded \n\n bad file name \n\n" + fileName$)
		RETURN
	END IF
'
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
'
' find funcName$ in PROLOG in text$[]
'
	DIM type$[11]
	type$[0] = ""
	type$[1] = "SBYTE "
	type$[2] = "UBYTE "
	type$[3] = "SSHORT "
	type$[4] = "USHORT "
	type$[5] = "SLONG "
	type$[6] = "ULONG "
	type$[7] = "XLONG "
	type$[8] = "GIANT "
	type$[9] = "SINGLE "
	type$[10] = "DOUBLE "
	type$[11] = "STRING "
'
	FOR i = 0 TO UBOUND(type$[])
		find$ = "DECLARE FUNCTION  " + type$[i] + funcName$
		line = 0
		pos = 0
  	XstFindArray (0, @text$[], @find$, @line, @pos, @match)
		IF match THEN
			declare$ = text$[line]
			type$ = type$[i]
			EXIT FOR
		END IF
	NEXT i
'
	IFZ match THEN
		FOR i = 0 TO UBOUND(type$[])
			line = 0
			pos = 0
			find$ = "INTERNAL FUNCTION  " + type$[i] + funcName$
  		XstFindArray (0, @text$[], @find$, @line, @pos, @match)
			IF match THEN
				declare$ = text$[line]
				type$ = type$[i]
				EXIT FOR
			END IF
		NEXT i
'
		IFZ match THEN
			Message (" ViewLoadFunctionFromProgram() \n\n function not found in PROLOG \n\n" + funcName$)
			RETURN
		END IF
	END IF
'
' find function, get start and end lines in text$[]
'
	len = LEN(find$)
	pos = pos + len
	find$ = "FUNCTION  " + type$ + funcName$ + " "
  XstFindArray (0, @text$[], @find$, @line, @pos, @match)
	start = line
'
	IFZ match THEN
		Message (" ViewImportFunctionFromProgram() \n\n function not found \n\n" + funcName$)
		RETURN
	END IF
'
	len = LEN(find$)
	find$ = "END FUNCTION"
	pos = pos + len
  XstFindArray (0, @text$[], @find$, @line, @pos, @match)
	end = line
'
	IFZ match THEN
		Message (" ViewImportFunctionFromProgram() \n\n end of function not found \n\n function \n\n" + funcName$)
		RETURN
	END IF
'
	upper = end-start+6-1
	DIM out$[upper]
	out$[0] = "'"
	out$[1] = "'"
	out$[2] = "' #######" + CHR$('#', LEN(funcName$)) + "##########"
	out$[3] = "' #####  " +					funcName$					+ " ()  #####"
	out$[4] = "' #######" + CHR$('#', LEN(funcName$)) + "##########"
	out$[5] = "'"
'
	FOR i = 6 TO upper
		out$[i] = text$[start+i-6]
	NEXT i
'
	XitSetDECLARE (@funcName$, @declare$)
	error = XitSetFunction (@funcName$, @out$[])
'
	XitSetDisplayedFunction (@funcName$)
END FUNCTION
'
'
' ##################################
' #####  XitOptionMiscCode ()  #####
' ##################################
'
FUNCTION  XitOptionMiscCode (grid, message, v0, v1, v2, v3, kid, r1)
	EXTERNAL /xxx/  checkBounds
	SHARED  optionMiscBox,  programAltered,  saveCRLF,  pasteCRLF
	SHARED	xitTextLower,  xitCommand
'
	$XitOptionMisc          =   0  ' kid   0 grid type = XitOptionMisc
	$CheckBounds            =   1  ' kid   1 grid type = XuiCheckBox
	$CheckSaveNewline       =   2  ' kid   2 grid type = XuiCheckBox
	$CheckConsoleDarkColor  =   3  ' kid   3 grid type = XuiCheckBox
	$CheckPasteNewline      =   4  ' kid   4 grid type = XuiCheckBox
	$CheckConsoleLargeFont  =   5  ' kid   5 grid type = XuiCheckBox
	$CheckProgramLargeFont  =   6  ' kid   6 grid type = XuiCheckBox
	$CheckConsoleLargeBars  =   7  ' kid   7 grid type = XuiCheckBox
	$CheckProgramLargeBars  =   8  ' kid   8 grid type = XuiCheckBox
	$ButtonEnter            =   9  ' kid   9 grid type = XuiPushButton
	$UpperKid               =   9  ' kid maximum
'
'	XgrMessageNumberToName (r1, @mess$)
'	XgrMessageNumberToName (message, @message$)
'	PRINT "XitOptionMisc() : "; grid;; message$;; v0; v1; v2; v3; kid; r1;; mess$
'
	IF (message = #Callback) THEN message = r1
'
	SELECT CASE message
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #Selection			: GOSUB Selection
	END SELECT
	RETURN
'
'
' *****  Selection  *****
'
SUB Selection
  SELECT CASE kid
	CASE $XitOptionMisc          :
	CASE $CheckBounds            : checkBounds = v0
	CASE $CheckSaveNewline       : saveCRLF = v0
	CASE $CheckConsoleDarkColor  : GOSUB ConsoleDarkColor
	CASE $CheckPasteNewline      : pasteCRLF = v0
	CASE $CheckConsoleLargeFont  : GOSUB ConsoleLargeFont
	CASE $CheckProgramLargeFont  : GOSUB ProgramLargeFont
	CASE $CheckConsoleLargeBars  : GOSUB ConsoleLargeBars
	CASE $CheckProgramLargeBars  : GOSUB ProgramLargeBars
	CASE $ButtonEnter            : XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
	END SELECT
END SUB
'
'
' *****  ConsoleDarkColor  *****
'
SUB ConsoleDarkColor
	XstGetConsoleGrid (@console)
'	PRINT "XitOptionMiscCode() : ConsoleDarkColor : "; console;; v0
	IF v0 THEN
		XuiSendMessage (console, #SetColor, $$Black, $$White, -1, -1, 1, 0)
	ELSE
		XuiSendMessage (console, #SetColor, $$BrightGrey, $$Black, -1, -1, 1, 0)
	END IF
	XuiSendMessage (console, #Redraw, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  ConsoleLargeFont  *****
'
SUB ConsoleLargeFont
	XstGetConsoleGrid (@console)
'	PRINT "XitOptionMiscCode() : ConsoleLargeFont : "; console;; v0
	IF v0 THEN
		XuiSendMessage (console, #SetFont, 320, 700, 0, 0, 0, @"Courier")
	ELSE
		XuiSendMessage (console, #SetFontNumber, 0, 0, 0, 0, 0, 0)
	END IF
	XuiSendMessage (console, #Redraw, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  ProgramLargeFont  *****
'
SUB ProgramLargeFont
'	PRINT "XitOptionMiscCode() : ProgramLargeFont : "; xitTextLower; xitCommand;; v0
	IF v0 THEN
		XuiSendMessage (xitTextLower, #SetFont, 320, 700, 0, 0, 0, @"Courier")
	ELSE
		XuiSendMessage (xitTextLower, #SetFontNumber, 0, 0, 0, 0, 0, 0)
	END IF
	XuiSendMessage (xitTextLower, #Redraw, 0, 0, 0, 0, 0, 0)
'
' code for old main window design
'
'	IF v0 THEN
'		XuiSendMessage (xitCommand, #SetFont, 320, 700, 0, 0, 0, @"Courier")
'	ELSE
'		XuiSendMessage (xitCommand, #SetFontNumber, 0, 0, 0, 0, 0, 0)
'	END IF
'	XuiSendMessage (xitCommand, #Redraw, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  ConsoleLargeBars  *****
'
SUB ConsoleLargeBars
	delta = -4
	IF v0 THEN delta = 4
	XstGetConsoleGrid (@console)
'	PRINT "XitOptionMiscCode() : ConsoleLargeBars : "; console;; v0
	XuiSendMessage (console, #GetSize, @x, @y, @w, @h, 0, 0)
	XuiSendMessage (console, #GetSize, @hx, @hy, @hw, @hh, 2, 0)
	XuiSendMessage (console, #GetSize, @vx, @vy, @vw, @vh, 3, 0)
	XuiSendMessage (console, #Resize, hx, hy-delta, hw-delta, hh+delta, 2, 0)
	XuiSendMessage (console, #Resize, vx-delta, vy, vw+delta, vh-delta, 3, 0)
	XuiSendMessage (console, #Resize, x, y, w, h, 0, 0)
	XuiSendMessage (console, #Redraw, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  ProgramLargeBars  *****
'
SUB ProgramLargeBars
	delta = -4
	IF v0 THEN delta = 4
'	PRINT "XitOptionMiscCode() : ProgramLargeFont : "; xitTextLower; xitCommand;; v0
	XuiSendMessage (xitTextLower, #GetSize, @x, @y, @w, @h, 0, 0)
	XuiSendMessage (xitTextLower, #GetSize, @hx, @hy, @hw, @hh, 2, 0)
	XuiSendMessage (xitTextLower, #GetSize, @vx, @vy, @vw, @vh, 3, 0)
	XuiSendMessage (xitTextLower, #Resize, hx, hy-delta, hw-delta, hh+delta, 2, 0)
	XuiSendMessage (xitTextLower, #Resize, vx-delta, vy, vw+delta, vh-delta, 3, 0)
	XuiSendMessage (xitTextLower, #Resize, x, y, w, h, 0, 0)
	XuiSendMessage (xitTextLower, #Redraw, 0, 0, 0, 0, 0, 0)
'	XuiSendMessage (xitCommand, #GetSize, @x, @y, @w, @h, 0, 0)
'	XuiSendMessage (xitCommand, #GetSize, @hx, @hy, @hw, @hh, 2, 0)
'	XuiSendMessage (xitCommand, #GetSize, @vx, @vy, @vw, @vh, 3, 0)
'	XuiSendMessage (xitCommand, #Resize, hx, hy-delta, hw-delta, hh+delta, 2, 0)
'	XuiSendMessage (xitCommand, #Resize, vx-delta, vy, vw+delta, vh-delta, 3, 0)
'	XuiSendMessage (xitCommand, #Resize, x, y, w, h, 0, 0)
'	XuiSendMessage (xitCommand, #Redraw, 0, 0, 0, 0, 0, 0)
END SUB
END FUNCTION
'
'
' ###############################
' #####  OptionTabWidth ()  #####
' ###############################
'
FUNCTION  OptionTabWidth (width)
	SHARED  xitGrid
	SHARED	stringBox
	SHARED	optTabBox
	SHARED	tabWidth
'
	skip = $$FALSE
	IF ((width >= 1) AND (width <= 256)) THEN tabWidth = width : skip = $$TRUE
	tabWidth$ = STRING (tabWidth)
	lenName = LEN (tabWidth$)
	XuiSendMessage (optTabBox, #SetTextString, lenName, 0, 0, 0, $$DialogText, tabWidth$)
	XuiSendMessage (optTabBox, #SetTextCursor, lenName, 0, 0, 0, $$DialogText, 0)
	IFZ width THEN
		response = 0
		XuiSendMessage (optTabBox, #GetModalInfo, @v0, 0, 0, 0, @response, 0)
		SELECT CASE response
			CASE 2		:	IF (v0{$$VirtualKey} = $$KeyEscape) THEN RETURN
			CASE 3		:	' OK button
			CASE 4		:	RETURN
			CASE ELSE	:	PRINT "OptionTabWidth() : unknown response ="; response
									RETURN
		END SELECT
		XuiSendMessage (optTabBox, #GetTextString, 0, 0, 0, 0, $$DialogText, @tabWidth$)
	END IF
'
	tabWidth = XLONG (tabWidth$)
	IF (tabWidth < 2) THEN tabWidth = 2
	IF (tabWidth > 256) THEN tabWidth = 256
'
'	XuiSendMessage (xitGrid, #SetTabWidth, tabWidth, 0, 0, 0, $$xitCommand, 0)
'	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitCommand, 0)
	XuiSendMessage (xitGrid, #SetTabWidth, tabWidth, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (stringBox, #SetTabWidth, tabWidth, 0, 0, 0, 3, 0)
	XuiSendMessage (stringBox, #RedrawText, 0, 0, 0, 0, 3, 0)
END FUNCTION
'
'
' #################################
' #####  OptionTextCursor ()  #####
' #################################
'
FUNCTION  OptionTextCursor (grid, message, v0, v1, v2, v3, kid, r1)
	SHARED  textCursor
	SHARED  xitGrid
'
	IF ((message = #Callback) AND (r1 = #Selection)) THEN
		IF (v0 = -1) THEN
			XuiSendMessage (textCursor, #HideWindow, 0, 0, 0, 0, 0, 0)
		ELSE
			IF ((v0 >= 1) OR (v0 <= 124)) THEN
				XxxXuiTextCursor (v0)
				hide = $$FALSE
			END IF
		END IF
	END IF
END FUNCTION
'
'
' ###########################
' #####  OptionFont ()  #####
' ###########################
'
'	Reset the environment fonts based on the Option Font box
'
'	Discussion:
'		xitCommand/xitTextLower/stringBox ONLY.
'			(leave assemblyBox alone as want its tabs at 8)
'
FUNCTION  OptionFont ()
	SHARED  xitGrid
	SHARED  optFontBox
	SHARED  popupGrids[]
'
	XuiSendMessage (optFontBox, #GetModalInfo, @font, 0, 0, 0, 0, 0)
	IF (font = -1) THEN RETURN						' KeyEscape or Cancel
	PRINT "OptionFont:  selected font "; font
	XgrGetFontInfo (font, @fontName$, @fontSize, @fontWeight, @fontItalic, @fontAngle)
	PRINT "  "; fontName$
	PRINT "  "; fontSize / 20; "  Point"
	PRINT "  "; fontWeight; "  Weight"
	IF fontItalic THEN PRINT "  Italic:  Yes" ELSE PRINT "  Italic:  No"
	PRINT "  "; fontAngle / 10; "  Degrees"

	XuiSendMessage (xitGrid, #SetFontNumber, font, 0, 0, 0, -1, 0)		' All kids
	XuiSendMessage (xitGrid, #Resize, 0, 0, 0, 0, 0, 0)
	XuiSendMessage (xitGrid, #RedrawWindow, 0, 0, 0, 0, 0, 0)
	FOR i = 0 TO UBOUND(popupGrids[])
		grid = popupGrids[i]
		XuiSendMessage (grid, #SetFontNumber, font, 0, 0, 0, -1, 0)			' All kids
		XuiSendMessage (grid, #Resize, 0, 0, 0, 0, 0, 0)
		XuiSendMessage (grid, #RedrawWindow, 0, 0, 0, 0, 0, 0)
	NEXT i
END FUNCTION
'
'
' #########################
' #####  RunStart ()  #####
' #########################
'
FUNCTION  RunStart ()
	SHARED  blowback,  userRun,  exitMainLoop
	SHARED  fileType,  xitGrid
'
	IF (fileType != $$Program) THEN
		Message (" RunStart() \n\n no program loaded ")
		RETURN
	END IF
'
	SELECT CASE TRUE
		CASE (##USERRUNNING AND (NOT ##SIGNALACTIVE))
					XitSoftBreak()
					blowback = $$TRUE
		CASE ##SIGNALACTIVE
					##SOFTBREAK = $$TRUE			' used in SYSTEMCALLs
					blowback = $$TRUE
	END SELECT
'
	userRun				= $$TRUE
	exitMainLoop	= $$TRUE
'
	XxxGuiDesignerOnOff (0)
	XuiSendMessage (xitGrid, #SetValues, 0, 0, 0, 0, 21, 0)
END FUNCTION
'
'
' ################################
' #####  ClearForCompile ()  #####
' ################################
'
FUNCTION  ClearForCompile ()
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  lineAddr[],  lineCode[],  lineUpper[],  lineLast[]
	SHARED  funcFirstAddr[],  funcAfterAddr[]

	ufunc = maxFuncNumber + 1			' last is for END PROGRAM
	DIM funcFirstAddr[ufunc]			' clear first-address in function array
	DIM funcAfterAddr[ufunc]			' clear after-address in function array
	DIM lineUpper[ufunc]					' clear upper bounds of lineaddr[]
	DIM lineLast[ufunc]						' clear next line # to compile in each func
	DIM lineAddr[ufunc,]					' addresses of lines in program
	DIM lineCode[ufunc,]					' 1st opcodes of lines in program

	uLine = 15
	funcNumber = 0
	DO UNTIL (funcNumber > ufunc)
		dimArrays = $$FALSE
		IF (funcNumber = ufunc) THEN
			dimArrays = $$TRUE
		ELSE
			IF prog[funcNumber,] THEN dimArrays = $$TRUE	' only dim defined functions
		END IF
		IF dimArrays THEN
			ATTACH lineAddr[funcNumber,] TO tempAddr[]
			ATTACH lineCode[funcNumber,] TO tempCode[]
			DIM tempAddr[uLine]						' clear addresses of all lines in pgm
			DIM tempCode[uLine]						' clear 1st opcodes of all lines in pgm
			ATTACH tempAddr[] TO lineAddr[funcNumber,]
			ATTACH tempCode[] TO lineCode[funcNumber,]
		END IF
		lineUpper[funcNumber] = uLine
		lineLast[funcNumber]  = 0
		INC funcNumber
	LOOP
END FUNCTION
'
'
' ###############################
' #####  CompileProgram ()  #####
' ###############################
'
' Returns $$FALSE if no errors, else $$TRUE or # of errors
'
FUNCTION  CompileProgram ()
	EXTERNAL /xxx/  i486asm,  i486bin,  maxFuncNumber,  entryFunction,  errorCount
	EXTERNAL /xxx/  checkBounds,  xpc
	SHARED  prog[]
	SHARED  funcAltered[],  funcBPAltered[],  funcNeedsTokenizing[]
	SHARED  funcCursorPosition[],  errorFunc[],  errorRawPtr[]
	SHARED  xitGrid,  editFunction,  priorFunction,  fileType
	SHARED  programAltered,  breakpointsAltered
	SHARED  softInterrupt,  codeSpaceResized,  errorBox
	SHARED  compiledCheckBounds
	SHARED  currentCursor
	SHARED  endProgram$[]
'
	entryCursor = currentCursor
'
' Make sure editFile is a source program... must have ".x" suffix
'
	IF (fileType != $$Program) THEN
		Message (" CompileProgram() \n\n no program loaded ")
		RETURN ($$TRUE)
	END IF

	redisplay = $$TRUE
	reportBogusRename = $$TRUE							' Retokenizes, sets BPs, if necessary
	RestoreTextToProg(redisplay, reportBogusRename)

	IFZ entryFunction THEN
		Message (" CompileProgram() \n\n no entry function declared ")
		RETURN ($$TRUE)
	END IF
	IFZ prog[entryFunction,] THEN
		Message (" CompileProgram() \n\n entry function not defined ")
		RETURN ($$TRUE)
	END IF
	IFZ programAltered THEN
		IF (checkBounds = compiledCheckBounds) THEN RETURN ($$FALSE)
	END IF
'
'	Grab required amount of memory
'		Allocate memory size based on number of lines:
'			xx6e.x:  26548 lines
'				normal compilation:		0x98470 = 623728. bytes -->  24 bytes/line
'		Round up to 500Kb boundary (0x80000)
'
	bytesPerLine = 25
	IF checkBounds THEN bytesPerLine = bytesPerLine + 40
	totalLines = 0
	FOR func = 0 TO maxFuncNumber
		IFZ prog[func,] THEN DO NEXT
		totalLines = totalLines + UBOUND(prog[func,]) + 1
	NEXT func
'	Message (" CompileProgram() \n\n compiling " + STRING$(totalLines) + " lines ")
	AddCommandItem ("compiling " + STRING$(totalLines) + " lines")
'
	codeSize = totalLines * bytesPerLine
	IF (codeSize < 0x80000) THEN
		codeSize = 0x80000
	ELSE
		codeSize = (codeSize + 0x80000) AND 0xFFF80000
	END IF
'
	currentCodeSize = ##UCODEZ - ##UCODE
	codeDiff = currentCodeSize - codeSize
	IF ((codeDiff < 0) OR (codeDiff > 0x80000)) THEN
		addr = MakeUserCodeSpace (codeSize)
		IFZ addr THEN
			PRINT "Could not allocate required user code space.  Abort compilation."
			RETURN ($$TRUE)
		END IF
	END IF

'	SetCursor ($$CursorWait)
	status = $$StatusCompiling
startCompilation:
	codeSpaceResized = $$FALSE
'
'	Clear any error codes from the tokens
'
	ClearErrors ()

	softInterrupt = $$FALSE
	SetCurrentStatus (status, 0)
	IF softInterrupt THEN
'		SetCursor (entryCursor)
		Message (" CompileProgram() \n\n compilation aborted ")
		RETURN ($$TRUE)
	END IF

	i486asm = $$FALSE
	i486bin = $$TRUE

	XxxInitVariablesPass1 ()	' initialize variables in preparation for compilation
	XxxCompilePrep ()					' clear DECLARE and DEFINED bits in all function tokens
	BreakClearArrays()				' clear breakAddr[] and breakCode[]
	ClearForCompile()					' clear lineAddr[], lineCode[], etc...

'	do Pass 1 on PROLOG
	ATTACH prog[0,] TO func[]
	uLine = UBOUND(func[])
	line = 0
	DO
		ATTACH func[line,] TO tok[]
'		IFZ tok[] THEN INC line : DO LOOP
		CompileLine (0, line, @tok[])
		ATTACH tok[] TO func[line,]
		IF codeSpaceResized THEN						' start over if code space resized
			ATTACH func[] TO prog[0,]
			status = $$StatusRecompiling
			GOTO startCompilation
		END IF
		INC line
		SELECT CASE FALSE
			CASE (line AND 0x3FF)	:	SetCurrentStatus (status, line)		' Update 1024
			CASE (line AND 0x0FF)	:	ClearMessageQueue ()
		END SELECT
		IF softInterrupt THEN
			ATTACH func[] TO prog[0,]
			IF (errorCount > 255) THEN
				Message (" CompileProgram() \n\n compilation aborted \n\n too many errors ")
			ELSE
				Message (" CompileProgram() \n\n compilation aborted ")
			END IF
			IF errorCount THEN GOTO ShowFirstError
'			SetCursor (entryCursor)
			RETURN ($$TRUE)
		END IF
	LOOP UNTIL (line > uLine)
	ATTACH func[] TO prog[0,]
	totalLines = uLine

	ATTACH prog[entryFunction,] TO func[]		' Make entry function first in memory
	uLine = UBOUND(func[])
	line = 0
	DO
		ATTACH func[line,] TO tok[]
'		IFZ tok[] THEN INC line : INC totalLines : DO LOOP
		CompileLine (entryFunction, line, @tok[])
		ATTACH tok[] TO func[line,]
		IF codeSpaceResized THEN						' start over if code space resized
			ATTACH func[] TO prog[entryFunction,]
			status = $$StatusRecompiling
			GOTO startCompilation
		END IF
		INC line
		INC totalLines
		SELECT CASE FALSE
			CASE (totalLines AND 0x3FF)	:	SetCurrentStatus (status, totalLines)		' Update 1024
			CASE (totalLines AND 0x0FF)	:	ClearMessageQueue ()
		END SELECT
		IF softInterrupt THEN
			ATTACH func[] TO prog[entryFunction,]
			IF (errorCount > 255) THEN
				Message (" CompileProgram() \n\n compilation aborted \n\n too many errors ")
			ELSE
				Message (" CompileProgram() \n\n compilation aborted ")
			END IF
			IF errorCount THEN GOTO ShowFirstError
'			SetCursor (entryCursor)
			RETURN ($$TRUE)
		END IF
	LOOP UNTIL (line > uLine)
	ATTACH func[] TO prog[entryFunction,]
'
	func = 1
	DO UNTIL (func > maxFuncNumber)
		IFZ prog[func,] THEN INC func: DO DO						' Skip empty slots
		IF (func = entryFunction) THEN INC func: DO DO	' entryFunction already done

		ATTACH prog[func,] TO func[]
		uLine = UBOUND(func[])
		line = 0
		DO UNTIL (line > uLine)
			ATTACH func[line,] TO tok[]
'			IFZ tok[] THEN INC line : INC totalLines : DO LOOP
			CompileLine (func, line, @tok[])
			ATTACH tok[] TO func[line,]
			IF codeSpaceResized THEN						' start over if code space resized
				ATTACH func[] TO prog[func,]
				status = $$StatusRecompiling
				GOTO startCompilation
			END IF
			INC line
			INC totalLines
			SELECT CASE FALSE
				CASE (totalLines AND 0x3FF)	:	SetCurrentStatus (status, totalLines)		' Update 1024
				CASE (totalLines AND 0x0FF)	:	ClearMessageQueue ()
			END SELECT
			IF softInterrupt THEN
				ATTACH func[] TO prog[func,]
				IF (errorCount > 255) THEN
					Message (" CompileProgram() \n\n compilation aborted \n\n too many errors ")
				ELSE
					Message (" CompileProgram() \n\n compilation aborted ")
				END IF
				IF errorCount THEN GOTO ShowFirstError
'				SetCursor (entryCursor)
				RETURN ($$TRUE)
			END IF
		LOOP
		ATTACH func[] TO prog[func,]
		INC func
	LOOP
	XxxParseSourceLine ("END PROGRAM", @tok[])
	CompileLine (maxFuncNumber + 1, 0, @tok[])
	IF codeSpaceResized THEN						' start over if code space resized
		status = $$StatusRecompiling
		GOTO startCompilation
	END IF
	LoadLineCodeArray ()
'
	AddCommandItem ("encountered " + STRING$(errorCount) + " errors")
'
	IF errorCount THEN
		Message (" CompileProgram() \n\n encountered " + STRING$(errorCount) + " errors ")
		GOTO ShowFirstError
	END IF
'
	programAltered = $$FALSE
	DIM endProgram$[]
	IF checkBounds THEN
		compiledCheckBounds = $$TRUE
	ELSE
		compiledCheckBounds = $$FALSE
	END IF
	breakpointsAltered = $$FALSE
	func = 0
	DO UNTIL (func > maxFuncNumber)
		IFZ prog[func,] THEN INC func: DO DO
		funcAltered[func] = $$FALSE
		funcBPAltered[func] = $$FALSE
		funcNeedsTokenizing[func] = $$FALSE
		INC func
	LOOP

	ResetDataDisplays ($$ResetAssembly)
'	SetCursor (entryCursor)
'	Message ("CompileProgram() \n\n compiled " + STRING$(totalLines) + " lines -> " + STRING$(xpc - ##UCODE) + " bytes ")
	AddCommandItem ("compiled " + STRING$(totalLines) + " lines -> " + STRING$(xpc - ##UCODE) + " bytes")
	RETURN ($$FALSE)
'
ShowFirstError:
	IF (errorFunc[1] != -2) THEN							' 1st is not Pass2
		priorFunction	= editFunction
		editFunction	= errorFunc[1]
		errorPos			= errorRawPtr[1]
		ATTACH prog[editFunction,] TO func[]			' huh???
		numLines = UBOUND(func[])
		FOR i = 0 TO numLines
			startToken = func[i,0]
			IF (startToken{$$BYTE1} = 1) THEN
				errorLine = i
				EXIT FOR
			END IF
		NEXT i
		ATTACH func[] TO prog[editFunction,]
'
'		Deparse to display the error codes
'
		TokenArrayToText (editFunction, @text$[])
		XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		XuiSendMessage (xitGrid, #SetTextCursor, errorPos, errorLine, -1, -1, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
		funcCursorPosition[editFunction, 0] = cursorLine
		funcCursorPosition[editFunction, 1] = cursorPos
		funcCursorPosition[editFunction, 2] = topLine
		funcCursorPosition[editFunction, 3] = topIndent
		funcCursorPosition[editFunction, 4] = xCursor
		funcCursorPosition[editFunction, 5] = yCursor

		UpdateFileFuncLabels (0, $$TRUE)					' Reset function name
	END IF

'	SetCursor (entryCursor)
	WizardCompErrors (errorBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
'
	RETURN (errorCount)
END FUNCTION
'
'
' ############################
' #####  RunContinue ()  #####
' ############################
'
FUNCTION  RunContinue ()
	SHARED  userContinue,  userStepType,  exitMainLoop
	SHARED  fileType
'
	IF (fileType != $$Program) THEN
		Message (" RunContinue() \n\n no program loaded ")
		RETURN
	END IF
'
	SELECT CASE TRUE
		CASE (##USERRUNNING AND ##SIGNALACTIVE)
				userStepType = $$BreakContinueRunning
				userContinue = $$TRUE
				exitMainLoop = $$TRUE
		CASE ##USERRUNNING
				Message (" RunContinue() \n\n program already running ")
		CASE ELSE
				Message (" RunContinue() \n\n program not running ")
	END SELECT
END FUNCTION
'
'
' ########################
' #####  RunJump ()  #####
' ########################
'
'	Set execution address at the cursor line.
'		Do NOT continue execution.
'
FUNCTION  RunJump ()
	SHARED  lineAddr[],  lineLast[]
	SHARED  programAltered,  userContinue,  userStepType
	SHARED  exeFunction,  exeLine,  editFunction,  exitMainLoop
	SHARED  fileType,  xitGrid
	SHARED  EXCEPTION_CONTEXT  exceptionContext
'
	IF (fileType != $$Program) THEN
		Message (" RunJump() \n\n no program loaded ")
		RETURN
	END IF
'
	SELECT CASE TRUE
		CASE (##USERRUNNING AND ##SIGNALACTIVE)
				IF (editFunction != exeFunction) THEN
					Message (" RunJump() \n\n cannot jump outside currently executing function ")
					RETURN
				END IF
				IF (exeFunction > UBOUND(lineLast[])) THEN
					Message (" RunJump() \n\n invalid function number (internal error) ")
					RETURN
				END IF
				XuiSendMessage (xitGrid, #GetTextCursor, 0, @cursorLine, 0, 0, $$xitTextLower, 0)
				IF (cursorLine > lineLast[exeFunction]) THEN
					Message (" RunJump() \n\n invalid line number ")
					RETURN
				END IF
				exceptionContext.eip = lineAddr[exeFunction, cursorLine]
'				##REG[$$SXIP] = SXIP OR 2				' not used says 88k documentation
'				##REG[$$SNIP] = SXIP OR 2				' 1st opcode to execute (V bit = 1)
'				##REG[$$SFIP] = (SXIP + 4) OR 2
				exeLine = cursorLine
				TokenArrayToText (exeFunction, @text$[])			' move '>'
				XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
				XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
		CASE ##USERRUNNING
				Message (" RunJump() \n\n program currently running ")
		CASE ELSE
				Message (" RunJump() \n\n program not running ")
	END SELECT
END FUNCTION
'
'
' #########################
' #####  RunPause ()  #####
' #########################
FUNCTION  RunPause ()
	SHARED  fileType
'
	IF (fileType != $$Program) THEN
		Message (" RunPause() \n\n no program loaded ")
		RETURN
	END IF
'
	XitSoftBreak ()
END FUNCTION
'
'
' ########################
' #####  RunKill ()  #####
' ########################
'
FUNCTION  RunKill ()
	SHARED  blowback,  exitMainLoop,  fileType
	SHARED  haltedByEdit
'
	IF (fileType != $$Program) THEN
		Message (" RunKill() \n\n no program loaded ")
		RETURN
	END IF
'
	IF ##USERRUNNING THEN
		IF (NOT ##SIGNALACTIVE) THEN
			##USERWAITING = $$FALSE							' unblock waiting in INLINE$() or ???
			XitSoftBreak()
		ELSE
			##USERWAITING = $$FALSE							' unblock waiting in INLINE$() or ???
			##SOFTBREAK = $$TRUE								' used in SYSTEMCALLs
		END IF
		exitMainLoop = $$TRUE
		haltedByEdit = $$TRUE
		blowback = $$TRUE
	END IF
END FUNCTION
'
'
' #############################
' #####  RunRecompile ()  #####
' #############################
'
FUNCTION  RunRecompile ()
	SHARED  programAltered
	SHARED  fileType
'
	IF (fileType != $$Program) THEN
		Message (" RunRecompile() \n\n no program loaded ")
		RETURN
	END IF
'
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN
		AddDispatch (&RunRecompile(), 0)
		XxxSetBlowback ()
		RETURN
	END IF
'
	programAltered = $$TRUE										' force recompilation
	CompileProgram ()
END FUNCTION
'
'
' ################################
' #####  CompileAssembly ()  #####
' ################################
'
FUNCTION  CompileAssembly ()
	EXTERNAL /xxx/  i486asm,  i486bin,  maxFuncNumber,  entryFunction,  errorCount
	EXTERNAL /xxx/  checkBounds,  library
	SHARED  prog[]
	SHARED  funcCursorPosition[],  errorFunc[],  errorRawPtr[]
	SHARED  xitGrid,  editFunction,  priorFunction,  fileType
	SHARED  errorBox,  editFilename$
	SHARED  programAltered,  softInterrupt
	SHARED  T_DECLARE,  T_INTERNAL,  T_EXTERNAL
	SHARED  T_FUNCTION, T_CFUNCTION,  T_SFUNCTION
	SHARED  currentCursor
'
	entryCursor = currentCursor
	IF (##USERRUNNING OR ##SIGNALACTIVE) THEN			' blowback before assembly
		AddDispatch (&RunAssembly(), 0)
		XxxSetBlowback ()
		RETURN
	END IF
'
	IF (fileType != $$Program) THEN
		Message (" RunAssembly() \n\n no program loaded ")
		RETURN
	END IF
'
	IF (LCASE$(RIGHT$(editFilename$, 2)) != ".x") THEN
		Message (" RunAssembly() \n\n filename must end with .x ")
		PRINT editFilename$
		RETURN
	END IF
'
	softInterrupt = $$FALSE
	SetCurrentStatus ($$StatusAssembling, 0)
	IF softInterrupt THEN
		Message (" RunAssembly() \n\n compilation aborted ")
		RETURN
	END IF
'
	redisplay = $$TRUE
	reportBogusRename = $$TRUE								' tokenize, set BPs (as necessary)
	RestoreTextToProg (redisplay, reportBogusRename)
'
'	Clear any error codes from the tokens
'
	ClearErrors ()
'
	IFZ entryFunction THEN
		Message (" RunAssembly() \n\n no entry function declared ")
		RETURN
	END IF
	IFZ prog[entryFunction,] THEN
		Message (" RunAssembly() \n\n entry function not defined ")
		RETURN
	END IF
'	SetCursor ($$CursorWait)
'
' By assembling, the user is forced to recompile before running
'
  IFZ programAltered THEN
    programAltered = $$TRUE
    ResetDataDisplays($$ResetAssembly)
  END IF
'
	bounds = checkBounds
	i486asm = $$TRUE
	i486bin = $$FALSE
	checkBounds = $$FALSE
'
	XxxInitVariablesPass1 ()	' initialize variables in preparation for compilation
	XxxCompilePrep ()					' clear DECLARE and DEFINED bits in all function tokens
	BreakClearArrays()				' clear breakAddr[] and breakCode[]
	ClearForCompile()					' clear lineAddr[], lineCode[], etc...
'
	programName$ = RCLIP$(editFilename$, 2)
	XxxSetProgramName (@programName$)
	XxxCreateCompileFiles()
'
	ATTACH prog[0,] TO func[]
	uLine = UBOUND(func[])
'
	DO
		ATTACH func[line,] TO tok[]
'		IFZ tok[] THEN INC pline : INC line : DO LOOP
		toks = tok[0]{$$BYTE0}
		INC pline
		asm$		= ""
		IF (toks > 1) THEN
			tokPtr	= 1
			IF NextXitToken(@tok[], @tokPtr, toks, @token) THEN
				IF (token{$$KIND} != $$KIND_COMMENTS) THEN
					CompileLine (0, line, @tok[])
				END IF
			END IF
		END IF
'
		ATTACH tok[] TO func[line,]
		INC line
		SELECT CASE FALSE
			CASE (line AND 0x3FF)	:	SetCurrentStatus ($$StatusAssembling, line)		' Update 1024
			CASE (line AND 0x0FF)	:	ClearMessageQueue ()
		END SELECT
		IF softInterrupt THEN
			ATTACH func[] TO prog[0,]
'			SetCursor (entryCursor)
			IF (errorCount > 255) THEN
				Message (" RunAssembly() \n\n compilation aborted \n\n too many errors ")
			ELSE
				Message (" RunAssembly() \n\n compilation aborted ")
			END IF
			IF errorCount THEN GOTO ShowFirstError
			checkBounds = bounds
			RETURN
		END IF
	LOOP UNTIL (line > uLine)
	ATTACH func[] TO prog[0,]
	totalLines = uLine
'
	func = 1
	DO UNTIL (func > maxFuncNumber)
		IFZ prog[func,] THEN INC func: DO DO
		ATTACH prog[func,] TO func[]
		uLine = UBOUND(func[])
		line = 0
		DO
			ATTACH func[line,] TO tok[]
'			IFZ tok[] THEN INC pline : INC line : DO LOOP
			toks = tok[0]{$$BYTE0}
			INC pline
			IF (toks > 1) THEN
				tokPtr = 1
				IF NextXitToken(@tok[], @tokPtr, toks, @token) THEN
					IF (token{$$KIND} != $$KIND_COMMENTS) THEN
						CompileLine (func, line, @tok[])
					END IF
				END IF
			END IF
			ATTACH tok[] TO func[line,]
			INC line
			INC totalLines
			SELECT CASE FALSE
				CASE (totalLines AND 0x3FF)	:	SetCurrentStatus ($$StatusAssembling, totalLines)		' Update 1024
				CASE (totalLines AND 0x0FF)	:	ClearMessageQueue ()
			END SELECT
			IF softInterrupt THEN
				ATTACH func[] TO prog[func,]
'				SetCursor (entryCursor)
				IF (errorCount > 255) THEN
					Message (" RunAssembly() \n\n compilation aborted \n\n too many errors ")
				ELSE
					Message (" RunAssembly() \n\n compilation aborted ")
				END IF
				IF errorCount THEN GOTO ShowFirstError
				RETURN
			END IF
		LOOP UNTIL (line > uLine)
		ATTACH func[] TO prog[func,]
		INC func
	LOOP
	INC pline
	XxxParseSourceLine ("END PROGRAM", @tok[])
	CompileLine (maxFuncNumber + 1, 0, @tok[])
	Message (" RunAssembly() \n\n encountered " + STRING$(errorCount) + " errors")
	IF errorCount THEN GOTO ShowFirstError
'
'	SetCursor (entryCursor)
	checkBounds = bounds
	RETURN
'
ShowFirstError:
	IF (errorFunc[1] != -2) THEN							' 1st is not Pass2
		priorFunction	= editFunction
		editFunction	= errorFunc[1]
		errorPos			= errorRawPtr[1]
		ATTACH prog[editFunction,] TO func[]			' huh???
		numLines = UBOUND(func[])
		FOR i = 0 TO numLines
			startToken = func[i,0]
			IF (startToken{$$BYTE1} = 1) THEN
				errorLine = i
				EXIT FOR
			END IF
		NEXT i
		ATTACH func[] TO prog[editFunction,]
'
'		Deparse to display the error codes
'
		TokenArrayToText (editFunction, @text$[])
		XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		XuiSendMessage (xitGrid, #SetTextCursor, errorPos, errorLine, -1, -1, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
		funcCursorPosition[editFunction, 0] = cursorLine
		funcCursorPosition[editFunction, 1] = cursorPos
		funcCursorPosition[editFunction, 2] = topLine
		funcCursorPosition[editFunction, 3] = topIndent
		funcCursorPosition[editFunction, 4] = xCursor
		funcCursorPosition[editFunction, 5] = yCursor
		UpdateFileFuncLabels (0, $$TRUE)					' Reset function name
	END IF
'	SetCursor (entryCursor)
	WizardCompErrors (errorBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
	checkBounds = bounds
	RETURN (errorCount)
END FUNCTION
'
'
' ############################
' #####  RunAssembly ()  #####
' ############################
'
FUNCTION  RunAssembly ()
	EXTERNAL /xxx/  library
	SHARED  fileType
'
	IF (fileType != $$Program) THEN
		Message (" RunAssembly() \n\n no program loaded ")
		RETURN
	END IF
'
	library = $$FALSE
	CompileAssembly ()
END FUNCTION
'
'
' ###########################
' #####  RunLibrary ()  #####
' ###########################
'
FUNCTION  RunLibrary ()
	EXTERNAL /xxx/  library
	SHARED  fileType
'
	IF (fileType != $$Program) THEN
		Message (" RunLibrary() \n\n no program loaded ")
		RETURN
	END IF
'
	library = $$TRUE
	CompileAssembly ()
	library = $$FALSE
END FUNCTION
'
'
' ############################
' #####  DebugToggle ()  #####
' ############################
'
'	Program mode only
'
FUNCTION  DebugToggle ()
	SHARED  prog[],  lineAddr[],  funcBPAltered[]
	SHARED  editFunction,  xitGrid,  breakpointsAltered
	SHARED  fileType
'
	IF (fileType != $$Program) THEN
		Message (" DebugToggleBreakpoint() \n\n no program loaded ")
		RETURN
	END IF
	IFZ prog[] THEN
		Message (" DebugToggleBreakpoint() \n\n no program loaded ")
		RETURN
	END IF
	IFZ editFunction THEN
		Message (" DebugToggleBreakpoint() \n\n breakpoints invalid in PROLOG ")
		RETURN
	END IF
'
	XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #GetTextCursor, 0, @cursorLine, 0, 0, $$xitTextLower, 0)
	IFZ text$[] THEN
		Message (" DebugToggle() \n\n empty function ")
		RETURN
	END IF
	text$ = text$[cursorLine]
'
	linePos = 0
	lenLine = LEN(text$)
	IFZ lenLine THEN
		text$[cursorLine] = ":"
		BPOn = $$TRUE
	ELSE
		cchar = text${0}
		SELECT CASE TRUE
			CASE (('0' <= cchar) AND (cchar <= '9'))				' errorCode
				linePos = 3
			CASE (cchar = '>')
				linePos = 1
		END SELECT
		IF (linePos < lenLine) THEN
			IF (text${linePos} = ':') THEN
				BPOn = $$FALSE
				text$[cursorLine] = LEFT$(text$, linePos) + MID$(text$, linePos + 2)
			ELSE
				BPOn = $$TRUE
				text$[cursorLine] = LEFT$(text$, linePos) + ":" + MID$(text$, linePos + 1)
			END IF
		END IF
	END IF
	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
'
	breakpointsAltered = $$TRUE
	funcBPAltered[editFunction] = $$TRUE
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN	' Add BP on the fly...
		lineAddr = lineAddr[editFunction, cursorLine]
'		MakeUserCodeRW ()																' NT: Not required
		IF BPOn THEN
			IF BreakProgrammer ($$BreakSetOne, lineAddr, 0) THEN
				IFZ #WINLESS THEN
					UBYTEAT (lineAddr) = $$BREAK1							' NT 1 byte
				ELSE
					USHORTAT (lineAddr) = $$BREAK2						' NT 2 byte
				END IF
			END IF
		ELSE
			BreakProgrammer ($$BreakClearOne, lineAddr, 0)
		END IF
'		MakeUserCodeRX ()																' NT: Not required
	END IF
END FUNCTION
'
'
' ###########################
' #####  DebugClear ()  #####
' ###########################
'
'	Program mode only
'
FUNCTION  DebugClear ()
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcBPAltered[]
	SHARED  editFunction,  xitGrid
	SHARED  breakpointsAltered,  fileType
'
	IF (fileType != $$Program) THEN
		Message (" DebugClearBreakpoints() \n\n no program loaded ")
		RETURN
	END IF
'
	IFZ prog[] THEN
		Message (" DebugClearBreakpoints() \n\n no program loaded ")
		RETURN
	END IF
'
	funcNumber = 0
	DO UNTIL (funcNumber > maxFuncNumber)
		IFZ prog[funcNumber,] THEN INC funcNumber: DO DO
		ATTACH prog[funcNumber,] TO func[]			' clear token arrays
		uLine = UBOUND(func[])
		line = 0
		DO UNTIL (line > uLine)
			startToken = func[line, 0]
			IF startToken{$$BP} THEN
				func[line, 0] = startToken{$$CLEAR_BP}
				breakpointsAltered = $$TRUE
				funcBPAltered[funcNumber] = $$TRUE
			END IF
			INC line
		LOOP
		ATTACH func[] TO prog[funcNumber,]
'
		IF (funcNumber = editFunction) THEN			' clear editFunction text
			XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			IFZ text$[] THEN
				INC funcNumber
				DO DO
			END IF
'
			FOR line = 0 TO UBOUND(text$[])
				IFZ text$[line] THEN DO NEXT
				linePos = 0
				lenLine = LEN(text$[line])
				cchar = text$[line]{0}
				SELECT CASE TRUE
					CASE (('0' <= cchar) AND (cchar <= '9'))				' errorCode
						linePos = 3
					CASE (cchar = '>')
						linePos = 1
				END SELECT
				IF (linePos >= lenLine) THEN DO NEXT
				IF (text$[line]{linePos} != ':') THEN DO NEXT			' no BP
				text$[line] = LEFT$(text$[line], linePos) + MID$(text$[line], linePos + 2)
'
				breakpointsAltered = $$TRUE
				funcBPAltered[editFunction] = $$TRUE
			NEXT line
			XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
		END IF
		INC funcNumber
	LOOP
'
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN		' Remove BPs on the fly...
'		MakeUserCodeRW ()																	' NT: Not required
		BreakProgrammer ($$BreakClearAll, 0, 0)
'		MakeUserCodeRX ()																	' NT: Not required
	END IF
END FUNCTION
'
'
' ###########################
' #####  DebugErase ()  #####
' ###########################
'
'	Program mode only
' Clear breakpoints in editFunction only
'
FUNCTION  DebugErase ()
	SHARED  prog[],  funcBPAltered[]
	SHARED  editFunction,  xitGrid
	SHARED  breakpointsAltered,  fileType
'
	IF (fileType != $$Program) THEN
		Message (" DebugEraseLocalBreakpoints() \n\n no program loaded ")
		RETURN
	END IF
'
	IFZ prog[] THEN
		Message (" DebugEraseLocalBreakpoints() \n\n no program loaded ")
		RETURN
	END IF
'
	ATTACH prog[editFunction,] TO func[]			' clear token arrays
	uLine = UBOUND(func[])
	line = 0
	DO UNTIL (line > uLine)
		startToken = func[line, 0]
		IF startToken{$$BP} THEN
			func[line, 0] = startToken{$$CLEAR_BP}
			breakpointsAltered = $$TRUE
			funcBPAltered[funcNumber] = $$TRUE
		END IF
		INC line
	LOOP
	ATTACH func[] TO prog[editFunction,]
'
	XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	IFZ text$[] THEN RETURN
'
	FOR line = 0 TO UBOUND(text$[])
		IFZ text$[line] THEN DO NEXT
		linePos = 0
		lenLine = LEN(text$[line])
		cchar = text$[line]{0}
		SELECT CASE TRUE
			CASE (('0' <= cchar) AND (cchar <= '9'))				' errorCode
				linePos = 3
			CASE (cchar = '>')
				linePos = 1
		END SELECT
		IF (linePos >= lenLine) THEN DO NEXT
		IF (text$[line]{linePos} != ':') THEN DO NEXT			' no BP
		text$[line] = LEFT$(text$[line], linePos) + MID$(text$[line], linePos + 2)

		breakpointsAltered = $$TRUE
		funcBPAltered[editFunction] = $$TRUE
	NEXT line
	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
'
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN		' Remove BPs on the fly...
'		MakeUserCodeRW ()																	' NT: Not required
		BreakProgrammer ($$BreakClearFunc, 0, editFunction)
'		MakeUserCodeRX ()																	' NT: Not required
	END IF
END FUNCTION
'
'
' ############################
' #####  DebugMemory ()  #####
' ############################
'
'	Debug Memory box
'
'	Discussion:
'		Clear       c             Display     d [<hexAddr> [<hexBytes>]]
'		Registers   r             Assembly    a [<hexAddr> [<hexBytes>]]
'		Memory Map  m             Fill        f <hexAddr> <hexBytes> <hexValue>
'		Locate      l <hexValue>  Substitute  s [<hexAddr>] <hexValue>
'
FUNCTION  DebugMemory (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	SHARED  fileType
	STATIC  lastSubAddr
	STATIC  UBYTE  charsetHexChar[]
'
	$textArea	= 1
	$textLine	= 2
	$button0	= 3
	$button1	= 4
'
	IFZ charsetHexChar[] THEN GOSUB Initialize
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  Selection  *****  r0 = 1234 = TextArea/Command/Button01
'
SUB Selection
	SELECT CASE r0
		CASE $textLine, $button0
					IF (r0 = $textLine) THEN
						IF (v0{$$VirtualKey} = $$KeyEscape) THEN
							XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
							EXIT SUB
						END IF
					END IF
					XuiSendMessage (grid, #GetTextString, 0, 0, 0, 0, $textLine, @command$)
					XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $textLine, "")
					XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textLine, 0)
					GOSUB ProcessCommand
		CASE $button1
					XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
	END SELECT
END SUB
'
'
' *****  ProcessCommand  *****
'
SUB ProcessCommand
	command$ = TRIM$(command$)
	IFZ command$ THEN EXIT SUB
'
	DIM args$[6]
	ParseLine$(command$, @args$[])
'
	c$ = LCASE$(LEFT$(args$[0], 1))
	text$ = args$[0]
	arg1$ = args$[1]:  IF (LEN(arg1$) <= 8) THEN arg1 = XLONG("0x" + arg1$)
	arg2$ = args$[2]:  IF (LEN(arg2$) <= 8) THEN arg2 = XLONG("0x" + arg2$)
	arg3$ = args$[3]:  IF (LEN(arg3$) <= 8) THEN arg3 = XLONG("0x" + arg3$)
	IF arg1$ THEN text$ = text$ + " " + arg1$
	IF arg2$ THEN text$ = text$ + " " + arg2$
	IF arg3$ THEN text$ = text$ + " " + arg3$
	SELECT CASE	c$
		CASE "a":		text$ = text$ + "\n" + XxxAsm$ (arg1, arg2)
		CASE "c":		DIM text$[]
								XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $textArea, @text$[])
								XuiSendMessage (grid, #SetTextCursor, 0, 0, 0, 0, $textArea, 0)
								XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textArea, 0)
								EXIT SUB
		CASE "d":		text$ = text$ + "\n" + Dump$ (arg1$, arg2$)
		CASE "f":		error = Fill (arg1$, arg2$, arg3$)
								SELECT CASE error
									CASE  0
									CASE -1			: text$ = text$ + "\n  Byte value only (0 - 0xFF)"
									CASE ELSE		: text$ = text$ + "\n  Invalid address"
								END SELECT
		CASE "h":		t1$ = " Clear       c             Display     d [<hexAddr> [<hexBytes>]]\n"
								t2$ = " Registers   r             Assembly    a [<hexAddr> [<hexBytes>]]\n"
								t3$ = " Memory Map  m             Fill        f <hexAddr> <hexBytes> <hexValue>\n"
								t4$ = " Substitute  s <hexAddr>   Locate      l <hexValue>\n"
								t4$ = " Locate      l <hexValue>  Substitute  s [<hexAddr>] <hexValue>"
								text$ = t1$ + t2$ + t3$ + t4$
		CASE "l":		text$ = text$ + "\n" + Locate$ (arg1$)
		CASE "m":		text$ = MemoryMap$ ()
		CASE "r":		text$ = RegisterString$()
		CASE "s":		SELECT CASE TRUE
									CASE arg2$											' have both address and value
												addr = arg1
												value$ = TRIM$(UCASE$(arg2$))
									CASE arg1$
												addr = lastSubAddr + 1
												value$ = TRIM$(UCASE$(arg1$))
									CASE ELSE
												text$ = text$ + "  <<<   Syntax Error"
												EXIT SELECT 2
								END SELECT
'
								lastSubAddr = addr
								sectionAddr = AddressOk (addr)
								SELECT CASE sectionAddr
									CASE 0
										text$ = text$ + "\n  ^^^  Invalid address:  " + HEX$(addr,8)
										EXIT SELECT 2

									CASE ##CODEZ
										text$ = text$ + "\n  ^^^  Cannot substitute in code space"
										EXIT SELECT 2

									CASE ##UCODEZ
										IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN
											text$ = text$ + "\n  ^^^  Cannot substitute in user space while running"
											EXIT SELECT 2
										END IF
								END SELECT

								lastChar = LEN(value$) - 1
								i = 0
								DO UNTIL (i > lastChar)
									oldValue = UBYTEAT(addr)
									c = value${i}:  INC i
									digit = charsetHexChar[c]
									IFZ digit THEN EXIT DO
									value = digit - '0'
									IF (i <= lastChar) THEN
										c = value${i}:  INC i
										digit = charsetHexChar[c]
										IF digit THEN
											value = (value << 4) + digit - '0'
										ELSE
											i = lastChar + 1				' Do this then exit
										END IF
									END IF
									UBYTEAT(addr) = value{8,0}
									newValue = UBYTEAT(addr)
									text$ = text$ + "\n" + HEX$(addr, 8) + ": " + HEX$(oldValue, 2) + " -> " + HEX$(newValue, 2)
									IF (newValue != value) THEN
										text$ = text$ + "\n    ^^^  Warning:  substitute failed!"
										EXIT DO
									END IF
									lastSubAddr = addr
									INC addr
								LOOP
		CASE "u":		text$ = text$ + "\n" + XxxAnyAsm$ (arg1, arg2)
		CASE ELSE:	text$ = text$ + "   <<<   Invalid command"
	END SELECT
'
'	Append new text
'
	XuiSendMessage (grid, #GrabTextArray, 0, 0, 0, 0, $textArea, @text$[])
	line = 0
	pos = 0
	cursorLine = 0
	IF text$[] THEN
		text$ = "\n" + text$
		line = UBOUND(text$[])
		pos = LEN(text$[line])
		cursorLine = line + 1
	END IF
	XuiSendMessage (grid, #PokeTextArray, 0, 0, 0, 0, $textArea, @text$[])
	XuiSendMessage (grid, #TextReplace, pos, line, pos, line, $textArea, @text$)
	XuiSendMessage (grid, #SetTextCursor, 0, cursorLine, 0, cursorLine, $textArea, 0)
	XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textArea, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	DIM charsetHexChar[255]
	FOR i = '0' TO '9'
		charsetHexChar[i] = i									' 0-9
	NEXT i
	FOR i = 'A' TO 'F'
		charsetHexChar[i] = i - 'A' + 0x3A		' 10-15
	NEXT i
END SUB
END FUNCTION
'
'
' ##############################
' #####  DebugAssembly ()  #####
' ##############################
'
'	Debug Assembly box
'
FUNCTION  DebugAssembly (grid, message, v0, v1, v2, v3, r0, (r1, r1$, r1$[]))
	SHARED  xitGrid,  editFunction,  programAltered,  fileType
'
	$label		= 1
	$textArea	= 2
	$button0	= 3
	$button1	= 4
	$button2	= 5
	$button3	= 6
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****  v0 = justUpdate
'
SUB DisplayWindow
	command = 0
	GOSUB ProcessCommand
	IFZ v0 THEN XuiSendToKid (grid, #DisplayWindow, 0, 0, 0, 0, 1, 0)
END SUB
'
'
' *****  Selection  *****  r0 = 3456 = Button0123
'
SUB Selection
	SELECT CASE r0
		CASE $button0:	command = 1
										GOSUB ProcessCommand
		CASE $button1:	command = 0
										GOSUB ProcessCommand
		CASE $button2:	command = -1
										GOSUB ProcessCommand
		CASE $button3:	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE $textArea:
			IF (v0{$$VirtualKey} = $$KeyEscape) THEN
				XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
			ELSE
				command = 1
				GOSUB ProcessCommand
			END IF
	END SELECT
END SUB
'
'
' *****  ProcessCommand  *****
'
SUB ProcessCommand
	SELECT CASE TRUE
		CASE (fileType != $$Program)
				asm$ = "* Unavailable:  TEXT mode *"
				label$ = ""
		CASE programAltered
				asm$ = "* Unavailable:  Code requires compilation *"
				label$ = ""
		CASE ELSE
				XuiSendMessage (xitGrid, #GetTextArrayBounds, 0, 0, @lastPos, @lastLine, $$xitTextLower, 0)
				XuiSendMessage (xitGrid, #GetTextCursor, 0, @lineNumber, 0, 0, $$xitTextLower, 0)
				startLine = lineNumber
				SELECT CASE command
					CASE 1														' next
								INC lineNumber
								IF (lineNumber > lastLine) THEN lineNumber = lastLine
					CASE -1														' back
								DEC lineNumber
								IF (lineNumber < 0) THEN lineNumber = 0
				END SELECT
				IF (startLine != lineNumber) THEN		' Move text cursor to the new line
					XuiSendMessage (xitGrid, #SetTextCursor, 0, @lineNumber, -1, -1, $$xitTextLower, 0)
					XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
				END IF
				asm$ = AssemblyString$ (editFunction, lineNumber)
				XxxFunctionName ($$XGET, @funcName$, editFunction)
				IF (LEN(funcName$) > 26) THEN
					funcName$ = LEFT$(funcName$, 25) + "*"
				END IF
				label$ = "FUNCTION:  " + funcName$ + "  LINE:  " + STRING$(lineNumber)
	END SELECT
	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $label, @label$)
	XuiSendMessage (grid, #Redraw, 0, 0, 0, 0, $label, 0)
	XstStringToStringArray (@asm$, @asm$[])
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $textArea, @asm$[])
	XuiSendMessage (grid, #SetTextCursor, 0, 0, 0, 0, $textArea, 0)
	XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textArea, 0)
END SUB
END FUNCTION
'
'
' ###############################
' #####  DebugRegisters ()  #####
' ###############################
'
FUNCTION  DebugRegisters (grid, message, v0, v1, v2, v3, r0, (r1, r1$, r1$[]))
	SHARED  regTemp[],  lineAddr[]
	SHARED  fileType,  exeFunction,  exeLine
	SHARED  EXCEPTION_RECORD  exceptionRecord
	SHARED  EXCEPTION_CONTEXT  exceptionContext
	SHARED  EXCEPTION_CONTEXT  exceptionContextOrig
'
	$label		= 1
	$textArea	= 2
	$textLine	= 3
	$button0	= 4
	$button1	= 5
	$button2	= 6
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****  v0 = justUpdate
'
SUB DisplayWindow
	IF (fileType = $$Program) THEN
		sxip = exceptionRecord.exceptionAddress
		IF exeFunction THEN
			IF exeLine THEN
				IF (sxip = lineAddr[exeFunction, exeLine]) THEN
					XxxFunctionName ($$XGET, @funcName$, exeFunction)
					IF (LEN(funcName$) > 45) THEN
						funcName$ = LEFT$(funcName$, 44) + "*"
					END IF
					label$ = "FUNCTION:  " + funcName$ + "  LINE:  " + STRING$(exeLine)
				END IF
			END IF
		END IF
		IFZ label$ THEN
			label$ = "address = " + HEX$(sxip, 8) + "   (not interior function line boundary)"
		END IF
	ELSE
		label$ = "address = " + HEX$(sxip, 8)
	END IF
	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $label, @label$)
'
	reg$ = RegisterString$()
	XstStringToStringArray (@reg$, @reg$[])
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $textArea, @reg$[])
	XuiSendMessage (grid, #SetTextCursor, 0, 0, 0, 0, $textArea, 0)
	XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textArea, 0)
	IFZ v0 THEN XuiSendToKid (grid, #DisplayWindow, 0, 0, 0, 0, 1, 0)
END SUB
'
'
' *****  Selection  *****  r0 = 3456 = Command/Button012
'
SUB Selection
	SELECT CASE r0
		CASE $button0		:	GOSUB SetCommand
		CASE $button1		:	GOSUB ResetCommand
		CASE $button2		:	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE $textLine
					IF (v0{$$VirtualKey} = $$KeyEscape) THEN
						XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
					ELSE
						GOSUB SetCommand
					END IF
	END SELECT
END SUB
'
'
' *****  SetCommand  *****
'			SET reads the register text and assigns the register's new value.
'				Redisplay registers
'			RESET restores all registers to initial values.
'
SUB SetCommand
	IFZ ((fileType = $$Program) AND (##USERRUNNING AND ##SIGNALACTIVE)) THEN
		ResetDataDisplays (0)
		temp$ = "program not active : cannot alter registers"
		XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $textLine, @temp$)
		XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textLine, 0)
		EXIT SUB
	END IF
	XuiSendMessage (grid, #GetTextString, 0, 0, 0, 0, $textLine, @command$)
	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $textLine, "")		' Clear
	XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textLine, 0)
'
'	One register at a time; value is in HEX
'
	colon = INSTR(command$, ":")
	IF (colon <= 1) THEN GOTO RegSyntax
	reg$ = LCASE$(LEFT$(command$, colon - 1))
	value$ = LCASE$(TRIM$(MID$(command$, colon + 1)))
	IF (LEFT$(value$,2) = "0x") THEN
		value = XLONG(value$)
	ELSE
		value = XLONG("0x" + value$)
	END IF

	SELECT CASE reg$
		CASE "eax":		exceptionContext.eax		= value
		CASE "ebx":		exceptionContext.ebx		= value
		CASE "ecx":		exceptionContext.ecx		= value
		CASE "edx":		exceptionContext.edx		= value
		CASE "edi":		exceptionContext.edi		= value
		CASE "esi":		exceptionContext.esi		= value
		CASE "ebp":		exceptionContext.ebp		= value
		CASE "esp":		exceptionContext.esp		= value
		CASE "eip":		exceptionContext.eip		= value
		CASE "flg":		exceptionContext.eFlags	= value
		CASE "cs":		exceptionContext.segCs	= value
		CASE "ds":		exceptionContext.segDs	= value
		CASE "es":		exceptionContext.segEs	= value
		CASE "fs":		exceptionContext.segFs	= value
		CASE "gs":		exceptionContext.segGs	= value
		CASE "ss":		exceptionContext.segSs	= value
		CASE ELSE:		GOTO RegSyntax
	END SELECT

'	Display new values
	reg$ = RegisterString$()
	XstStringToStringArray (@reg$, @reg$[])
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $textArea, @reg$[])
	XuiSendMessage (grid, #SetTextCursor, 0, 0, 0, 0, $textArea, 0)
	XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textArea, 0)
	EXIT SUB

RegSyntax:
	temp$ = "* Syntax =  reg: hexValue *"
	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $textArea, @temp$)
	XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textArea, 0)
END SUB
'
'
' *****  ResetCommand  *****  RESET restores all registers to initial values, redisplay registers.
'
SUB ResetCommand
	FOR i = 0 TO (SIZE(EXCEPTION_CONTEXT) >> 2) - 1
		XLONGAT(&exceptionContext,[i]) = XLONGAT(&exceptionContextOrig,[i])
	NEXT i
	reg$ = RegisterString$()
	XstStringToStringArray (@reg$, @reg$[])
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $textArea, @reg$[])
	XuiSendMessage (grid, #SetTextCursor, 0, 0, 0, 0, $textArea, 0)
	XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textArea, 0)
END SUB
END FUNCTION
'
'
' ############################
' #####  ClearErrors ()  #####
' ############################
'
'	Clear all error numbers from the token array
' Reset the compilation error box
'
FUNCTION  ClearErrors ()
	EXTERNAL /xxx/ maxFuncNumber,  errorCount
	SHARED  prog[]
	SHARED  funcCursorPosition[]
	SHARED  errorCurrent
	SHARED  xitGrid,  editFunction,  fileType
	SHARED  currentCursor

	IF (fileType != $$Program) THEN RETURN
	IFZ prog[] THEN RETURN

	entryCursor = currentCursor
'	SetCursor($$CursorWait)

	redisplay = $$FALSE
	reportBogusRename = $$TRUE								' tokenize, set BPs (as necessary)
	RestoreTextToProg (redisplay, reportBogusRename)

	FOR func = 0 TO maxFuncNumber
		IFZ prog[func,] THEN DO NEXT
		ATTACH prog[func,] TO func[]
		numLines = UBOUND(func[])
		FOR line = 0 TO numLines
			startToken = func[line,0]
			IF startToken{$$BYTE1} THEN
				func[line,0] = startToken AND 0xFFFF00FF
			END IF
		NEXT line
		ATTACH func[] TO prog[func,]
	NEXT func
'
'	Redisplay editFunction in case any changes occured
'
	TokenArrayToText (editFunction, @text$[])
	XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
	errorCount = 0
	errorCurrent = 0
	UpdateErrors (0, 0)
END FUNCTION
'
'
' #############################
' #####  UpdateErrors ()  #####
' #############################
'
'	Update the compilation error box with the requested func/line.  Manage the box.
'
'	In:				func			function number containing this error
'						line			function line with this error
'	Out:			none			(args unchanged)
'	Return:		none
'
'	Discussion:
'		Minor kludge:		func == -2								END PROGRAM
'
FUNCTION  UpdateErrors (func, line)
	EXTERNAL /xxx/ errorCount
	SHARED  errorXerror[],  errorRawPtr[]
	SHARED  errorSrcPtr[],  errorSrcLine$[]
	SHARED  errorCurrent
	SHARED  errorBox
'
	SELECT CASE TRUE
		CASE (errorCount = 0)
			XuiSendMessage (errorBox, #SetTextString, 0, 0, 0, 0, 1, @" no errors detected ")
			XuiSendMessage (errorBox, #SetTextString, 0, 0, 0, 0, 2, "")
		CASE (func = -2)																' END PROGRAM
			symbol$	= errorSrcLine$[errorCurrent]
'			token		= errorRawPtr[errorCurrent]
			addr		= errorSrcPtr[errorCurrent]
			xerror	= errorXerror[errorCurrent]
			srcLine$ = RIGHT$("00" + STRING$(errorCurrent), 3) + ":  " + HEXX$(addr, 8) + "  "
			pointer = LEN(srcLine$) + 1
			srcLine$ = srcLine$ + symbol$
			XuiSendMessage (errorBox, #SetTextString, 0, 0, 0, 0, 1, @srcLine$)
			errMsg$ = LEFT$(XxxGetXerror$(xerror), 32)
			label$ = SPACE$(pointer - 1) + "^-- " + errMsg$
			XuiSendMessage (errorBox, #SetTextString, 0, 0, 0, 0, 2, @label$)
		CASE ELSE
			srcLine$ = errorSrcLine$[errorCurrent]
			pointer = errorSrcPtr[errorCurrent]
			xerror = errorXerror[errorCurrent]
			lenSrc = LEN(srcLine$)
			IF (pointer < 78) THEN
				IF (lenSrc >= 78) THEN
					srcLine$ = LEFT$(srcLine$, 77) + "..."
				END IF
			ELSE
				IF (ABS(lenSrc - pointer) < 40) THEN
					srcLine$ = "..." + RIGHT$(srcLine$, 77)			' Show tail end of line
					pointer = 3 + (pointer - (lenSrc - 77))
				ELSE
					middle$ = MID$(srcLine$, pointer - 36, 74)
					srcLine$ = "..." + middle$ + "..."					' Show line middle
					pointer = 40
				END IF
			END IF
			srcLine$ = RIGHT$("00" + STRING$(errorCurrent), 3) + ":  " + srcLine$
			pointer = pointer + 6
			XuiSendMessage (errorBox, #SetTextString, 0, 0, 0, 0, 1, @srcLine$)
'
'			Error messages to the right or left of pointer
'
			errMsg$ = LEFT$(XxxGetXerror$ (xerror), 32)			' msgs <= 32 chars)
			IF (pointer > 40) THEN
				label$ = RJUST$(errMsg$, pointer - 4) + " --^"
			ELSE
				label$ = SPACE$(pointer - 1) + "^-- " + errMsg$
			END IF
			XuiSendMessage (errorBox, #SetTextString, 0, 0, 0, 0, 2, @label$)
'
'			Show the function/line. Move pointer to the raw character offset.
'				Note: Once user edits this line, raw offset will be goofy.  This is why
'							I provide the offset in the error box with the original source line.
'
			cursorPos = 3 + errorRawPtr[errorCurrent]				' 3 digit error code
			Display (func, line, cursorPos, -1, -1)
	END SELECT
'
	XuiSendMessage (errorBox, #GetSize, 0, 0, @width, @height, 0, 0)
	XuiSendMessage (errorBox, #GetSmallestSize, 0, 0, @v2, @v3, 0, 0)
	IF (width < v2) THEN
		XuiSendMessage (errorBox, #Resize, -1, -1, v2, v3, 0, 0)
		XuiSendMessage (errorBox, #Redraw, 0, 0, 0, 0, 0, 0)
	ELSE
		XuiSendMessage (errorBox, #RedrawGrid, 0, 0, 0, 0, 1, 0)
		XuiSendMessage (errorBox, #RedrawGrid, 0, 0, 0, 0, 2, 0)
	END IF
END FUNCTION
'
'
' #################################
' #####  WizardCompErrors ()  #####
' #################################
'
FUNCTION  WizardCompErrors (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	EXTERNAL /xxx/  maxFuncNumber,  errorCount
	SHARED  prog[]
	SHARED  errorXerror[],  errorFunc[],  errorRawPtr[]
	SHARED  errorSrcPtr[],  errorSrcLine$[]
	SHARED  uError
	SHARED  fileType,  xitGrid,  editFunction
	SHARED  errorCurrent
'
	$label0		= 1
	$label1		= 2
	$button0	= 3
	$button1	= 4
	$button2	= 5
	$button3	= 6
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: GOSUB HideWindow
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****
'
SUB DisplayWindow
	showError = 1
	GOSUB ShowError
	XuiSendToKid (grid, #DisplayWindow, 0, 0, 0, 0, 1, 0)
END SUB
'
'
' *****  HideWindow  *****
'
SUB HideWindow
	XuiSendToKid (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  Selection  *****  r0 = 3456 = Button0123
'
SUB Selection
	SELECT CASE r0
		CASE $button0:	showError =  1:		GOSUB ShowError
		CASE $button1:	showError =  0:		GOSUB ShowError
		CASE $button2:	showError = -1:		GOSUB ShowError
		CASE $button3:	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE 0:
			IF (v0{$$VirtualKey} = $$KeyEscape) THEN
				XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
			ELSE
				showError = 1:		GOSUB ShowError
			END IF
	END SELECT
END SUB
'
'
' *****  ShowError  *****
'
SUB ShowError
	IF (fileType != $$Program) THEN GOTO NoErrorsDetected
	IFZ prog[] THEN GOTO NoErrorsDetected
	IF (errorCount > uError) THEN errorCount = uError
'
	IF errorCount THEN
		redisplay = $$TRUE
		reportBogusRename = $$TRUE							' tokenize, set BPs (as necessary)
		RestoreTextToProg (redisplay, reportBogusRename)
'
'		Check the "forward" half of the error list
'
		SELECT CASE showError
			CASE 1:
				firstError = errorCurrent + 1
				IF (firstError > errorCount) THEN firstError = 1
				lastError = errorCount
				errorStep = 1
			CASE 0:
				firstError = errorCurrent
				lastError = errorCount
				errorStep = 1
			CASE ELSE:
				firstError = errorCurrent - 1
				IF (firstError < 1) THEN firstError = errorCount
				lastError = 1
				errorStep = -1
		END SELECT

		FOR i = firstError TO lastError STEP errorStep
			func = errorFunc[i]
			IF (func = -2) THEN									' -2 == END PROGRAM
				errorCurrent = i
				GOTO ShowError
			END IF
			IF (func < 0) THEN DO NEXT					' This error has been fixed
			IF (func > maxFuncNumber) THEN
				errorFunc[i] = -1
				DO NEXT
			END IF
			IFZ prog[func,] THEN
				errorFunc[i] = -1
				DO NEXT
			END IF

			ATTACH prog[func,] TO func[]
			numLines = UBOUND(func[])
			FOR line = 0 TO numLines
				startToken = func[line,0]
				thisError = startToken{$$BYTE1}
				IF (thisError = i) THEN
					ATTACH func[] TO prog[func,]
					errorCurrent = i
					GOTO ShowError
				END IF
			NEXT line
			ATTACH func[] TO prog[func,]

			errorFunc[i] = -1										' error code has been removed
		NEXT i
'
'		Check the "behind" half of the error list
'
		SELECT CASE showError
			CASE 1:
				IF (firstError = 1) THEN GOTO NoErrorsDetected
				firstError = 1
				lastError = errorCurrent
				errorStep = 1
			CASE 0:
				IF (firstError = 1) THEN GOTO NoErrorsDetected
				firstError = 1
				lastError = errorCurrent - 1
				errorStep = 1
			CASE ELSE:
				IF (firstError = errorCount) THEN GOTO NoErrorsDetected
				firstError = errorCount
				lastError = errorCurrent
				errorStep = -1
		END SELECT

		FOR i = firstError TO lastError STEP errorStep
			func = errorFunc[i]
			IF (func = -2) THEN									' -2 == END PROGRAM
				errorCurrent = i
				GOTO ShowError
			END IF
			IF (func < 0) THEN DO NEXT					' This error has been fixed
			IF (func > maxFuncNumber) THEN
				errorFunc[i] = -1
				DO NEXT
			END IF
			IFZ prog[func,] THEN
				errorFunc[i] = -1
				DO NEXT
			END IF

			ATTACH prog[func,] TO func[]
			numLines = UBOUND(func[])
			FOR line = 0 TO numLines
				startToken = func[line,0]
				thisError = startToken{$$BYTE1}
				IF (thisError = i) THEN
					ATTACH func[] TO prog[func,]
					errorCurrent = i
					GOTO ShowError
				END IF
			NEXT line
			ATTACH func[] TO prog[func,]
			errorFunc[i] = -1										' error code has been removed
		NEXT i
	END IF

NoErrorsDetected:
	errorCount = 0
	errorCurrent = 0

ShowError:
	UpdateErrors (func, line)
END SUB
END FUNCTION
'
'
' ################################
' #####  WizardRunErrors ()  #####
' ################################
'
FUNCTION  WizardRunErrors (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
'
	$label0	= 1
	$label1	= 2
	$button	= 3
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  Selection  *****  r0 = 3 = Button
'
SUB Selection
	SELECT CASE r0
		CASE 0, $button:	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
	END SELECT
END SUB
END FUNCTION
'
'
' ##################################
' #####  ClearRuntimeError ()  #####
' ##################################
'
'	Clear the Runtime Error box
'
FUNCTION  ClearRuntimeError ()
	SHARED  environmentActive,  runtimeErrorBox
'
	IF environmentActive THEN
		XuiSendMessage (runtimeErrorBox, #SetTextString, 0, 0, 0, 0, 1, "")
		XuiSendMessage (runtimeErrorBox, #RedrawGrid, 0, 0, 0, 0, 1, 0)
		XuiSendMessage (runtimeErrorBox, #SetTextString, 0, 0, 0, 0, 2, "")
		XuiSendMessage (runtimeErrorBox, #RedrawGrid, 0, 0, 0, 0, 2, 0)
	END IF
END FUNCTION
'
'
' ###################################
' #####  UpdateRuntimeError ()  #####
' ###################################
'
' Update the Runtime Error box with current exception
'
FUNCTION  UpdateRuntimeError ()
	SHARED  environmentActive,  runtimeErrorBox
'
	showMsg = GetRuntimeError (@runtimeInfo$, @runtimeMsg$)
	IFZ environmentActive THEN
		IF showMsg THEN
			PRINT runtimeInfo$
			PRINT runtimeMsg$
			a$ = INLINE$("  PRESS RETURN TO CONTINUE (q to quit) ")
			IF (a$ = "q") THEN XitQuit(0)
		END IF
	ELSE
		XuiSendMessage (runtimeErrorBox, #SetTextString, 0, 0, 0, 0, 1, @runtimeInfo$)
		XuiSendMessage (runtimeErrorBox, #SetTextString, 0, 0, 0, 0, 2, @runtimeMsg$)
		XuiSendMessage (runtimeErrorBox, #RedrawGrid, 0, 0, 0, 0, 1, 0)
		XuiSendMessage (runtimeErrorBox, #RedrawGrid, 0, 0, 0, 0, 2, 0)
		XuiSendMessage (runtimeErrorBox, #GetSmallestSize, 0, 0, @v2, 0, 0, 0)
		XuiSendMessage (runtimeErrorBox, #GetSize, 0, 0, @width, @height, 0, 0)
		IF (width < v2) THEN
			XuiSendMessage (runtimeErrorBox, #Resize, -1, -1, v2, v3, 0, 0)
			XuiSendMessage (runtimeErrorBox, #Redraw, 0, 0, 0, 0, 0, 0)
		END IF
		IF showMsg THEN
			XuiSendMessage (runtimeErrorBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		END IF
	END IF
END FUNCTION
'
'
' ##########################
' #####  HelpIndex ()  #####
' ##########################
'
FUNCTION  HelpIndex ()
	STATIC state
	PRINT "*****  HelpIndex  *****"
'
	state = NOT state
	PRINT "HelpIndex:  Toggle GuiDesigner ";
	IF state THEN PRINT "On" ELSE PRINT "Off"
	XxxGuiDesignerOnOff(state)
END FUNCTION
'
'
' #############################
' #####  HelpContents ()  #####
' #############################
'
FUNCTION  HelpContents ()
	PRINT "*****  HelpContents  *****"
END FUNCTION
'
'
' ##############################
' #####  HelpHighlight ()  #####
' ##############################
'
FUNCTION  HelpHighlight ()
	SHARED  teston
'
	PRINT "*****  HelpHighlight  *****"
	PRINT "  Test TestHeaders()  CountHeaders()"
'
	entryTeston = teston
	teston = $$TRUE
	TestHeaders ()
	teston = entryTeston
'
	CountHeaders ()
END FUNCTION
'
'
' ##########################
' #####  HelpAbout ()  #####
' ##########################
'
FUNCTION  HelpAbout (display)
	SHARED  welcomeGrid
	SHARED  welcomeFont
	SHARED  welcome$
'
	IFZ #displayWidth THEN XgrGetDisplaySize ("", @#displayWidth, @#displayHeight, @#windowBorderWidth, @#windowTitleHeight)
'
	IFZ welcomeGrid THEN
		left = #windowBorderWidth
		upper = #windowBorderWidth + #windowTitleHeight
		halfWidth = (#displayWidth >> 1) - #windowBorderWidth - #windowBorderWidth
		halfHeight = (#displayHeight >> 1) - #windowBorderWidth - #windowBorderWidth - #windowTitleHeight
		XuiMessage1B   (@welcomeGrid, #CreateWindow, left, upper, halfWidth, halfHeight, 0, 0)
		XuiSendMessage ( welcomeGrid, #SetCallback, welcomeGrid, &WelcomeWindowCode(), -1, -1, -1, welcomeGrid)
		XuiSendMessage ( welcomeGrid, #SetColor, $$BrightBlue, $$Yellow, $$Black, $$BrightYellow, 1, 0)
		XuiSendMessage ( welcomeGrid, #SetColorExtra, $$Cyan, $$Yellow, $$Black, $$BrightYellow, 1, 0)
		XuiSendMessage ( welcomeGrid, #SetColor, $$BrightCyan, -1, -1, -1, 2, 0)
		XuiSendMessage ( welcomeGrid, #SetWindowTitle, 0, 0, 0, 0, 0, @" initialize ")
		XuiSendMessage ( welcomeGrid, #SetTexture, $$TextureShadow, 0, 0, 0, 1, 0)
		XuiSendMessage ( welcomeGrid, #SetTextString, 0, 0, 0, 0, 1, @welcome$)
		XuiSendMessage ( welcomeGrid, #SetTextSpacing, 0, -4, 0, 0, 1, 0)
		XuiSendMessage ( welcomeGrid, #Resize, 0, 0, halfWidth, halfHeight, 0, 0)
		XuiSendMessage ( welcomeGrid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
		XuiSendMessage ( welcomeGrid, #SetGridProperties, -1, 0, 0, 0, 0, 0)
		XuiSendMessage ( welcomeGrid, #SetFontNumber, welcomeFont, 0, 0, 0, 1, 0)
		XuiSendMessage ( welcomeGrid, #GetSize, @xx, @yy, @ww, @hh, 0, 0)
		XuiSendMessage ( welcomeGrid, #Resize, 0, 0, ww, hh, 0, 0)
		XuiSendMessage ( welcomeGrid, #ResizeWindow, left, upper, ww, hh, 0, 0)
	END IF
'
	IF display THEN
		XuiSendMessage (welcomeGrid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		XgrProcessMessages (-2)
	END IF
END FUNCTION
'
'
' ############################
' #####  HotToCursor ()  #####
' ############################
'
FUNCTION  HotToCursor ()
	SHARED  userRun,  userContinue,  userStepType,  programAltered
	SHARED  exitMainLoop,  fileType
'
	IF (fileType != $$Program) THEN
		Message (" HotToCursor() \n\n no program loaded ")
		RETURN
	END IF
'
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN
		Message (" HotToCursor() \n\n program already running ")
		RETURN
	END IF
'
	userStepType = $$BreakContinueToCursor
	IF (##USERRUNNING AND (NOT programAltered)) THEN
		userContinue = $$TRUE
	ELSE
		userRun = $$TRUE
	END IF
	exitMainLoop = $$TRUE
END FUNCTION
'
'
' #############################
' #####  HotStepLocal ()  #####
' #############################
'
FUNCTION  HotStepLocal ()
	SHARED  userRun,  userContinue,  userStepType,  programAltered
	SHARED  exitMainLoop,  fileType
'
	IF (fileType != $$Program) THEN
		Message (" HotStepLocal() \n\n no program loaded ")
		RETURN
	END IF
'
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN
		Message (" HotStepLocal() \n\n program already running ")
		RETURN
	END IF
'
	userStepType = $$BreakContinueStepLocal
	IF (##USERRUNNING AND (NOT programAltered)) THEN
		userContinue = $$TRUE
	ELSE
		userRun = $$TRUE
	END IF
	exitMainLoop = $$TRUE
END FUNCTION
'
'
' ##############################
' #####  HotStepGlobal ()  #####
' ##############################
'
FUNCTION  HotStepGlobal ()
	SHARED  userRun,  userContinue,  userStepType,  programAltered
	SHARED  exitMainLoop,  fileType
'
	IF (fileType != $$Program) THEN
		Message (" HotStepGlobal() \n\n no program loaded ")
		RETURN
	END IF
'
	IF (##USERRUNNING AND (NOT ##SIGNALACTIVE)) THEN
		Message (" HotStepGlobal() \n\n program already running ")
		RETURN
	END IF
'
	userStepType = $$BreakContinueStepGlobal
	IF (##USERRUNNING AND (NOT programAltered)) THEN
		userContinue = $$TRUE
	ELSE
		userRun = $$TRUE
	END IF
	exitMainLoop = $$TRUE
END FUNCTION
'
'
' #############################
' #####  HotVariables ()  #####
' #############################
'
FUNCTION  HotVariables (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	SHARED  variableFuncRow[]
	SHARED  variableUp,  arrayUp,  arrayBox,  exeFunction
	SHARED  stringUp,  stringBox,  compositeUp,  compositeBox
	SHARED  fileType
'
	$functionLabel	=  1
	$columnLabel		=  2
	$list						=  3
	$findLabel			=  4
	$findText				=  5
	$valueLabel			=  6
	$valueText			=  7
	$button0				=  8
	$button1				=  9
	$button2				= 10
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow
		CASE #HideWindow		: GOSUB HideWindow
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: GOSUB HideWindow
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****  Raise to top if already up : v0 = update
'
SUB DisplayWindow
	IF (fileType = $$Program) THEN
		IF v0 THEN UpdateVariables ()
		IF arrayUp THEN VariablesArray (arrayBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		IF stringUp THEN VariablesString (stringBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		IF compositeUp THEN VariablesComposite (compositeBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
	END IF
	XuiSendMessage (grid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
	variableUp = $$TRUE
END SUB
'
'
' *****  HideWindow  *****
'
SUB HideWindow
	IF arrayUp THEN VariablesArray (arrayBox, #HideWindow, 0, 0, 0, 0, 0, 0)
	IF stringUp THEN VariablesString (stringBox, #HideWindow, 0, 0, 0, 0, 0, 0)
	IF compositeUp THEN VariablesComposite (compositeBox, #HideWindow, 0, 0, 0, 0, 0, 0)
	IF variableUp THEN
		XuiSendMessage (grid, #GetTextCursor, 0, @cursorLine, 0, @topLine, $list, 0)
		IF variableFuncRow[] THEN
			variableFuncRow[exeFunction, 0] = topLine
			variableFuncRow[exeFunction, 1] = cursorLine
		END IF
		XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		variableUp = $$FALSE
	END IF
END SUB
'
'
' *****  Selection  *****
'
SUB Selection
	SELECT CASE r0
		CASE $findText
			IF (v0{$$VirtualKey} = $$KeyEscape) THEN
				GOSUB HideWindow
			ELSE
				VariablesFind ()
			END IF
		CASE $valueText
			IF (v0{$$VirtualKey} = $$KeyEscape) THEN
				GOSUB HideWindow
			ELSE
				IF variableFuncRow[] THEN
					XuiSendMessage (grid, #GetTextCursor, 0, @cursorLine, 0, @topLine, $list, 0)
					variableFuncRow[exeFunction, 0] = topLine
					variableFuncRow[exeFunction, 1] = cursorLine
					VariablesNewValue ()
				END IF
			END IF
		CASE $button0
			IF variableFuncRow[] THEN
				XuiSendMessage (grid, #GetTextCursor, 0, @cursorLine, 0, @topLine, $list, 0)
				variableFuncRow[exeFunction, 0] = topLine
				variableFuncRow[exeFunction, 1] = cursorLine
				VariablesNewValue ()
			END IF
		CASE $button1
			IF variableFuncRow[] THEN
				XuiSendMessage (grid, #GetTextCursor, 0, @cursorLine, 0, @topLine, $list, 0)
				variableFuncRow[exeFunction, 0] = topLine
				variableFuncRow[exeFunction, 1] = cursorLine
				VariablesDetail ()
			END IF
		CASE $button2
			GOSUB HideWindow
	END SELECT
END SUB
END FUNCTION
'
'
' ################################
' #####  UpdateVariables ()  #####
' ################################
'
'	Update the Variables box for current Frames function and line.
'
FUNCTION  UpdateVariables ()
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  lineAddr[],  lineLast[],  variableFuncRow[]
	SHARED  varTok[],  varSymbol$[],  varReg[],  varAddr[],  varDataAddr[]
	SHARED  varTypes$[],  reg86$[]
	SHARED  variableBox,  framesBox
	SHARED  arrayUp,  stringUp,  compositeUp
	SHARED  FRAMEINFO  frameInfo[]
	SHARED  FRAMEINFO  variableFrame
	SHARED  fileType,  programAltered
	SHARED  softInterrupt
	SHARED  EXCEPTION_RECORD  exceptionRecord
	SHARED  EXCEPTION_CONTEXT  exceptionContext
	SHARED  currentCursor
	STATIC  typeSuffix$[]
	STATIC  FRAMEINFO  zero
	AUTOX   copyString$,  topPosition
'
	IFZ typeSuffix$[] THEN GOSUB InitArrays
'
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
	entryCursor = currentCursor
'
' Clear New Value
'
	XuiSendMessage (variableBox, #SetTextString, 0, 0, 0, 0, 7, "")
	XuiSendMessage (variableBox, #RedrawText, 0, 0, 0, 0, 7, 0)
	XuiSendMessage (framesBox, #GetTextCursor, 0, @viewLine, 0, 0, 2, 0)
	XuiSendMessage (framesBox, #GetTextArrayLine, viewLine, 0, 0, 0, 2, @view$)
'
	frameItem = XLONG(view$)
	showFuncNumber	= frameInfo[frameItem].funcNumber
	IF (showFuncNumber <= 0) THEN GOTO Invalid
	IF (showFuncNumber != variableFrame.funcNumber) THEN
		IF arrayUp THEN VariablesArray (arrayBox, #HideWindow, 0, 0, 0, 0, 0, 0)
		IF stringUp THEN VariablesString (stringBox, #HideWindow, 0, 0, 0, 0, 0, 0)
		IF compositeUp THEN VariablesComposite (compositeBox, #HideWindow, 0, 0, 0, 0, 0, 0)
	END IF
'
	variableFrame = zero
	showFrameAddr = frameInfo[frameItem].frameAddr
	showFuncAddr = frameInfo[frameItem].funcAddr
	showFuncLine = frameInfo[frameItem].funcLine
'
	softInterrupt = $$FALSE
	lastLine = lineLast[showFuncNumber]
	lineAddr = lineAddr[showFuncNumber, showFuncLine]
	firstAddr = lineAddr[showFuncNumber, 0]
	FOR line = 0 TO lastLine
		secondAddr = lineAddr[showFuncNumber, line]
		IF (secondAddr != firstAddr) THEN EXIT FOR
	NEXT line
'
'	Can't access variables:
'		showFuncAddr not in current function
'				Intrinsics create new frames, etc
'		First line (the FUNCTION line):
'				This is a branch to the function entry point.
'					Cannot access variables because function frame is not set up yet.
'					This can be hit in the entry function, but never in other functions.
'		showFuncAddr = ##UCODE
'				Can't yield variables at the ##UCODE, nothing is set up yet.  This is
'					only hit in the entry function where no code is emitted in the prolog.
'		showFuncAddr != lineAddr
'				- NOT OK if last line (exit code)
'				- NT:  everything else OK
'						BECAUSE all variables are either absolute address or
'							offset from ebp
'
	nextAddr = lineAddr[showFuncNumber, showFuncLine + 1]
	IF ((showFuncAddr < lineAddr) OR (showFuncAddr >= nextAddr)) THEN
		error$ = "* Outside function:  variable state unknown *"
		GOTO ShowError
	END IF
'
	IF (lineAddr < secondAddr) THEN
		error$ = "* Unavailable on FUNCTION line *"
		GOTO ShowError
	END IF
'
	IF (showFuncAddr = ##UCODE) THEN
		error$ = "* Unavailable on first PROGRAM line *"
		GOTO ShowError
	END IF
'
'	Not OK if inside last line
'
	IF (showFuncAddr != lineAddr) THEN
		IF (showFuncLine = lastLine) THEN
			error$ = "* Not line boundary:  unavailable inside END FUNCTION *"
			GOTO ShowError
		END IF
'
'		Tests for prior to function call not necessary for NT:
'			- OK if no function call in this line
'			- If function call, ok if prior to first push/esp/call
'					- NEVER ok if after call (may have pass by reference stuff)
'
'		ATTACH prog[showFuncNumber, showFuncLine, ] TO tok[]
'		IFZ tok[] THEN RETURN													' avoid access error
'		toks = tok[0]{$$BYTE0}
'		IF toks THEN
'			tokPtr = 1
'			DO
'				IFZ NextXitToken(@tok[], @tokPtr, toks, @token) THEN EXIT DO
'				IF (token{$$KIND} = $$KIND_FUNCTIONS) THEN
'
'					Is showFuncAddr prior to first push/esp/call?
'
'					IF (showFuncAddr > lineAddr + 12) THEN
'						FOR addr = lineAddr TO (showFuncAddr - 16) STEP 4
'							i$ = XxxDisassemble$(addr, $$FALSE)
'							IF (INSTRI(i$, "push") || INSTRI(i$, "esp") || INSTRI(i$, "call")) THEN
'								ATTACH tok[] TO prog[showFuncNumber, showFuncLine, ]
'								error$ = "* Not line boundary:  unavailable during function call *"
'								GOTO ShowError
'							END IF
'						NEXT addr
'					END IF
'					EXIT DO
'				END IF
'			LOOP
'			ATTACH tok[] TO prog[showFuncNumber, showFuncLine, ]
'		END IF
	END IF
'
'	Get the current user composite type names
'
	XxxGetUserTypes (@varTypes$[])
'
'	Just get variables and arrays for now
'
	DIM kinds[1]
	kinds[0] = $$KIND_VARIABLES
	kinds[1] = $$KIND_ARRAYS
	numVars = XxxGetFunctionVariables (showFuncNumber, @kinds[], @varTok[], @varSymbol$[], @varReg[], @varAddr[])
	DIM varDataAddr[numVars - 1]

	IFZ numVars THEN
		DIM textArray$[0]
		textArray$[0] = "* No variables or arrays in this function *"
		DIM kinds[]
		DIM varTok[]
		DIM varSymbol$[]
		DIM varReg[]
		DIM varAddr[]
	ELSE
		VariableSort (@varTok[], @varSymbol$[], @varReg[], @varAddr[], 0, numVars - 1)
		DIM textArray$[numVars - 1]
'		GOSUB LoadRegisterValues				' NOT USED  4/12/93
		FOR i = 0 TO (numVars - 1)
			token = varTok[i]
			kind = token{$$KIND}
			tt = XxxTheType (token, showFuncNumber)
'
			validType = $$TRUE
			IF (tt < 0x20) THEN						' check for non-supported simple types
				IFZ varTypes$[tt] THEN
					validType = $$FALSE
				END IF
			ELSE
				IF (tt > UBOUND(varTypes$[])) THEN				' This is a compiler error
					validType = $$FALSE
				END IF
			END IF

			IF varReg[i] THEN
'				Register offset:  varReg[i]		= register used (usually ebp)
'													varAddr[i]	= signed offset (eg -8)
				register = varReg[i]
				IF (register != 31) THEN
					error$ = "* Error:  Register offset from " + reg86$[register] + " (not ebp) *"
					GOTO ShowError
				END IF
				base		= showFrameAddr
				offset	= varAddr[i]
				location$ = LJUST$(reg86$[register] + SIGNED$(offset), 10)		' pad
			ELSE
'				EXTERNAL
				base	= varAddr[i]
				offset = 0
				location$ = HEXX$(base,8)
			END IF
			word1 = XLONGAT(base, offset)
			offset = offset + 4
			word2 = XLONGAT(base, offset)
'
			IFZ validType THEN
				type$ = "        "
				hexValue$ = "                 "
				value$ = "<unsupported>"
			ELSE
				type$ = varTypes$[tt]
				IF (tt > 0x21) THEN
					lenType = LEN(type$)
					SELECT CASE TRUE
						CASE (lenType > 8)
							type$ = LEFT$(type$, 7) + "*"
						CASE (lenType < 8)
							type$ = LJUST$(type$, 8)
					END SELECT
				END IF
'
				hexValue$ = " " + LJUST$(HEX$(word1, 8), 16)
				IF (token{$$KIND} = $$KIND_ARRAYS) THEN
					varDataAddr[i] = word1									' array data addr
					value$ = " <array>"
					IFZ word1 THEN
						hexValue$ = " EMPTY           "
					ELSE
						hexValue$ = "@" + LJUST$(HEX$(word1, 8), 16)
					END IF
				ELSE
					SELECT CASE TRUE
						CASE (tt >= 0x20)											' composites
							value$ = " <composite>"
							IFZ word1 THEN
								hexValue$ = " EMPTY           "
							ELSE
								hexValue$ = "@" + LJUST$(HEX$(word1, 8), 16)
							END IF

						CASE (tt = $$STRING)
							addrOK = $$FALSE
							IF AddressOk(word1) THEN
								IFZ (word1 AND 3) THEN
'									infoWord = XLONGAT (word1, -4)				' old alloc word 3
									infoWord = XLONGAT (word1, -12)			' new alloc word 1
									IF (infoWord < 0) THEN addrOK = $$TRUE
								END IF
							END IF
							IFZ addrOK THEN
								value$ = " <INVALID> "
							ELSE
								copyString$ = ""								' make a copy of word1 string
								handle = &&copyString$
								XLONGAT (handle) = word1
								value$ = LEFT$(copyString$, 61)
								XLONGAT (handle) = 0								' but don't free word1
								value$ = XstBinStringToBackString$ (@value$)
								IF (LEN(value$) > 61) THEN
									value$ = " \"" + LEFT$ (value$, 60) + "\"*"
								ELSE
									value$ = " \"" + value$ + "\""
								END IF
							END IF
							IFZ word1 THEN
								hexValue$ = " EMPTY           "
							ELSE
								hexValue$ = "@" + LJUST$(HEX$(word1, 8), 16)
							END IF

						CASE (tt = $$GIANT)
							value$$		= GMAKE(word2, word1)
							value$		= STR$(value$$)
							hexValue$	= " " + HEX$(value$$,16)

						CASE (tt = $$SINGLE)
							value! = SMAKE(word1)
							value$ = STR$(value!)

						CASE (tt = $$DOUBLE)
							value# = DMAKE(word2, word1)
							value$ = STR$(value#)
							hexValue$ = " " + HEX$(word2,8) + HEX$(word1,8)

						CASE (tt = $$GOADDR), (tt = $$SUBADDR), (tt = $$FUNCADDR)
							value$ = " < undetermined > "
							labels = XxxGetLabelGivenAddress (word1, @labels$[])
							IF (tt = $$FUNCADDR) THEN
								XxxPassFunctionArrays ($$XGET, @funcSymbol$[], @funcToken[], @funcScope[])
							END IF
							FOR j = 0 TO (labels - 1)
								label$ = labels$[j]
								SELECT CASE tt
									CASE $$GOADDR						' %g%<user's GOTO label>%<func#>
										IF (LEFT$(label$, 3) = "%g%") THEN
											value$ = " " + MID$(label$, 4)
											ipercent = RINSTR (value$, "%")
											IF ipercent THEN value$ = LEFT$(value$, ipercent - 1)
											EXIT FOR
										END IF
									CASE $$SUBADDR					' %s%<user's SUB label>%<func#>
										IF (LEFT$(label$, 3) = "%s%") THEN
											value$ = " " + MID$(label$, 4)
											ipercent = RINSTR(value$, "%")
											IF ipercent THEN value$ = LEFT$(value$, ipercent - 1)
											EXIT FOR
										END IF
									CASE ELSE
										label$ = MID$(label$, 2)				' Strip leading _
										iat = RINSTR (label$, "@")			' Strip trailing @###
										IF iat THEN label$ = LEFT$(label$, iat - 1)
										FOR funcNumber = 0 TO maxFuncNumber
											IF funcSymbol$[funcNumber] THEN
												IF (label$ = funcSymbol$[funcNumber]) THEN
													value$ = " " + label$
													EXIT FOR 2
												END IF
											END IF
										NEXT funcNumber
								END SELECT
							NEXT j
							IF (LEN(value$) > 64) THEN
								value$ = LEFT$(value$, 63) + "*"
							END IF
							IF (tt = $$FUNCADDR) THEN
								XxxPassFunctionArrays ($$XSET, @funcSymbol$[], @funcToken[], @funcScope[])
							END IF

						CASE (tt = $$ULONG)
							value$ = STR$(ULONG(word1))

						CASE ELSE
							value$ = STR$(word1)
					END SELECT
				END IF  ' kind = array
			END IF	' unsupported type

			symbol$ = varSymbol$[i]
			lenSymbol = LEN(symbol$)
			SELECT CASE TRUE
				CASE (lenSymbol < 20)							' pad symbol to 20 chars
					symbol$ = LJUST$(symbol$, 20)

				CASE (lenSymbol > 20)							' truncate symbol to 20 chars
					IF (token{$$KIND} = $$KIND_ARRAYS) THEN		' Retain type suffix and []
						symbol$ = RCLIP$(symbol$, 2)	' strip []
						top = 18
					ELSE
						top = 20
					END IF
					SELECT CASE tt
						CASE $$UBYTE, $$USHORT, $$ULONG, $$GIANT
							IF (RIGHT$(symbol$, 2) = typeSuffix$[tt]) THEN
								symbol$ = LEFT$(symbol$, top - 3) + "*" + typeSuffix$[tt]
							ELSE
								symbol$ = LEFT$(symbol$, top - 1) + "*"
							END IF
						CASE ELSE
							IF (tt < 0x20) THEN
								IF (RIGHT$(symbol$, 1) = typeSuffix$[tt]) THEN
									symbol$ = LEFT$(symbol$, top - 2) + "*" + typeSuffix$[tt]
									EXIT SELECT
								END IF
							END IF
							symbol$ = LEFT$(symbol$, top - 1) + "*"
					END SELECT
					IF (token{$$KIND} = $$KIND_ARRAYS) THEN
						symbol$ = symbol$ + "[]"								' add []
					END IF
					varSymbol$[i] = symbol$				' varSymbol$ is 20 chars max
					lenSymbol = 20
			END SELECT

			textArray$[i] = type$ + "  " + symbol$ + "  " + location$ + "  " + hexValue$ + " " + value$

			IFZ (i AND 0xFF) THEN												' Update every 64 lines
				SetCurrentStatus ($$StatusFormatting, i)
				IF softInterrupt THEN
					Message ("UpdateVariables() : variable update aborted")
'					SetCursor (entryCursor)
					RETURN
				END IF
'				SetCursor ($$CursorWait)
			END IF
		NEXT i
	END IF		' numVars > 0
	variableFrame.frameAddr		= showFrameAddr
	variableFrame.funcNumber	= showFuncNumber
	variableFrame.funcAddr		= showFuncAddr
	variableFrame.funcLine		= showFuncLine

ShowVars:
	XxxFunctionName ($$XGET, @funcName$, showFuncNumber)
	IF (LEN(funcName$) > 50) THEN
		funcName$ = LEFT$(funcName$, 49) + "*"
	END IF
	label$ = "FUNCTION:    " + funcName$ + "    LINE:  " + STRING$(showFuncLine)
	XuiSendMessage (variableBox, #SetTextString, 0, 0, 0, 0, 1, @label$)
	XuiSendMessage (variableBox, #RedrawGrid, 0, 0, 0, 0, 1, 0)
'
	IFZ variableFuncRow[] THEN
		DIM variableFuncRow[maxFuncNumber, 1]
		topChar = 0
		cursorChar = 0
	ELSE
		utop = UBOUND(variableFuncRow[])
		IF (utop < maxFuncNumber) THEN
			REDIM variableFuncRow[maxFuncNumber, 1]
		END IF
		func = variableFuncRow[0, 0]						' PROLOG slot used for current func
		IF func THEN														' top character / cursor
			XuiSendMessage (variableBox, #GetTextCursor, 0, @cursorLine, 0, @topLine, 3, 0)
			variableFuncRow[func, 0] = topLine
			variableFuncRow[func, 1] = cursorLine
		END IF
		topLine = variableFuncRow[showFuncNumber, 0]
		cursorLine = variableFuncRow[showFuncNumber, 1]
	END IF
	variableFuncRow[0, 0] = showFuncNumber
	XuiSendMessage (variableBox, #SetTextArray, 0, 0, 0, 0, 3, @textArray$[])
	XuiSendMessage (variableBox, #SetTextCursor, 0, cursorLine, 0, topLine, 3, 0)
	XuiSendMessage (variableBox, #RedrawText, 0, 0, 0, 0, 3, 0)
'	SetCursor (entryCursor)
	RETURN

ShowError:
	DIM textArray$[0]
	ATTACH error$ TO textArray$[0]
	GOTO ShowVars

Invalid:
	DIM text$[0]
	text$[0] = "* Unavailable: No variables in PROLOG *"
	XuiSendMessage (variableBox, #SetTextArray, 0, 0, 0, 0, 3, @text$[])
	XuiSendMessage (variableBox, #SetTextCursor, 0, 0, 0, 0, 3, 0)
	XuiSendMessage (variableBox, #RedrawText, 0, 0, 0, 0, 3, 0)
	XuiSendMessage (variableBox, #SetTextString, 0, 0, 0, 0, 1, "")
	XuiSendMessage (variableBox, #RedrawGrid, 0, 0, 0, 0, 1, 0)
'	SetCursor (entryCursor)
	RETURN

SUB InitArrays
	DIM varTypes$[0x21]															' Establish accessible types
	DIM typeSuffix$[0x21]
	varTypes$[$$SBYTE]		= "SBYTE   "	: typeSuffix$[$$SBYTE]  = "@"
	varTypes$[$$UBYTE]		= "UBYTE   "	: typeSuffix$[$$UBYTE]  = "@@"
	varTypes$[$$SSHORT]		= "SSHORT  "	: typeSuffix$[$$SSHORT] = "%"
	varTypes$[$$USHORT]		= "USHORT  "	: typeSuffix$[$$USHORT] = "%%"
	varTypes$[$$SLONG]		= "SLONG   "	: typeSuffix$[$$SLONG]  = "&"
	varTypes$[$$ULONG]		= "ULONG   "	: typeSuffix$[$$ULONG]  = "&&"
	varTypes$[$$XLONG]		= "XLONG   "	: typeSuffix$[$$XLONG]  = "~"
	varTypes$[$$GOADDR]		= "GOADDR  "
	varTypes$[$$SUBADDR]	= "SUBADDR "
	varTypes$[$$FUNCADDR]	= "FUNCADDR"
	varTypes$[$$GIANT]		= "GIANT   "	: typeSuffix$[$$GIANT]  = "$$"
	varTypes$[$$SINGLE]		= "SINGLE  "	: typeSuffix$[$$SINGLE] = "!"
	varTypes$[$$DOUBLE]		= "DOUBLE  "	: typeSuffix$[$$DOUBLE] = "#"
	varTypes$[$$STRING]		= "STRING  "	: typeSuffix$[$$STRING] = "$"
	varTypes$[$$SCOMPLEX]	= "SCOMPLEX"
	varTypes$[$$DCOMPLEX]	= "DCOMPLEX"

	DIM reg86[31]
	DIM reg86$[31]
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
	reg86$[11] = "edx"
	reg86$[12] = "ebx"
	reg86$[13] = "ecx"
	reg86$[26] = "esi"
	reg86$[27] = "edi"
	reg86$[28] = "ecx"
	reg86$[29] = "edx"
	reg86$[31] = "ebp"
END SUB

SUB LoadRegisterValues
'	NO LONGER USED:  compiler only uses ebp offsets for variables
'		These values are ONLY valid for exeFunction/exeLine anyway.
'
'	variables are at offset to register values (eg ebp-8)
'		no variable is a register value in 80x86 versions
'
	EXIT SUB
	reg86[ 1] = exceptionContext.esp
	reg86[ 2] = exceptionContext.eax{8,0}			' al
	reg86[ 3] = exceptionContext.edx{8,0}			' dl
	reg86[ 4] = exceptionContext.ebx{8,0}			' bl
	reg86[ 5] = exceptionContext.ecx{8,0}			' cl
	reg86[ 6] = exceptionContext.eax{16,0}		' ax
	reg86[ 7] = exceptionContext.edx{16,0}		' dx
	reg86[ 8] = exceptionContext.ebx{16,0}		' bx
	reg86[ 9] = exceptionContext.ecx{16,0}		' cx
	reg86[10] = exceptionContext.eax
	reg86[11] = exceptionContext.edx
	reg86[12] = exceptionContext.ebx
	reg86[13] = exceptionContext.ecx
	reg86[26] = exceptionContext.esi
	reg86[27] = exceptionContext.edi
	reg86[28] = exceptionContext.ecx
	reg86[29] = exceptionContext.edx
	reg86[31] = exceptionContext.ebp
END SUB
END FUNCTION
'
'
' ##############################
' #####  VariablesFind ()  #####
' ##############################
'
'	Find the requested symbol in the Variable box and center it
'
FUNCTION  VariablesFind ()
	SHARED  varSymbol$[],  variableFuncRow[]
	SHARED  exeFunction
	SHARED  variableBox
'
' Get the symbol to find
'
	XuiSendMessage (variableBox, #GetTextString, 0, 0, 0, 0, 5, @findSymbol$)
	XuiSendMessage (variableBox, #SetTextString, 0, 0, 0, 0, 5, "")
	XuiSendMessage (variableBox, #RedrawText, 0, 0, 0, 0, 5, 0)
'
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
	IFZ varSymbol$[] THEN RETURN
	IFZ findSymbol$ THEN RETURN
'
'	Which symbol?
'
	lenFind = LEN(findSymbol$)
	lastVar = UBOUND(varSymbol$[])
	FOR index = 0 TO lastVar
		IF (findSymbol$ = LEFT$(varSymbol$[index], lenFind)) THEN EXIT FOR
	NEXT index
	IF (index > lastVar) THEN RETURN			' no match
'
	XuiSendMessage (variableBox, #SetTextCursor, -1, index, -1, -1, 3, 0)
	XuiSendMessage (variableBox, #GetTextCursor, 0, @cursorLine, 0, @topLine, 3, 0)
'
	variableFuncRow[exeFunction, 0] = topLine
	variableFuncRow[exeFunction, 1] = cursorLine
END FUNCTION
'
'
' ##################################
' #####  VariablesNewValue ()  #####
' ##################################
'
'	Assign the specified simple variable the requested new value
'
'	Discussion:
'		Engaged by:	 RETURN in variable NewValue grid
'			Valid for all simple types (including STRING), but not arrays and composites
'
FUNCTION  VariablesNewValue ()
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  varTok[],  varSymbol$[],  varReg[],  varAddr[],  varTypes$[]
	SHARED  reg86$[]
	SHARED  FRAMEINFO  variableFrame
	SHARED  funcFirstAddr[],  funcAfterAddr[]
	SHARED  exeFunction
	SHARED  variableBox
	AUTOX  newValue$
'
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
'	Get the new value
'
	XuiSendMessage (variableBox, #GetTextString, 0, 0, 0, 0, 7, @newValue$)
	newValue$ = TRIM$(newValue$)
'	PRINT "New value: '"; newValue$; "'"

	IFZ newValue$ THEN													' no new value
		RETURN
	END IF
'
' Get the variable
'
	XuiSendMessage (variableBox, #GetTextCursor, 0, @cursorLine, 0, 0, 3, 0)
	index = cursorLine
	lastVar = UBOUND(varSymbol$[])
	symbol$ = varSymbol$[index]

	token = varTok[index]											' better be simple type
	IF (token{$$KIND} != $$KIND_VARIABLES) THEN GOTO SimpleTypesOnly

	tt = XxxTheType (token, exeFunction)
	IF ((kind = $$KIND_ARRAYS) OR (tt >= 0x20)) THEN
		GOTO SimpleTypesOnly
	END IF
	IFZ varTypes$[tt] THEN GOTO UnsupportedType
'
'	Prepare new values for memory (word1/word2) AND new hexValue$, value$
'		for Variables display
'
	SELECT CASE tt
		CASE $$STRING
			IF (newValue$ = "\"\"") THEN			' "" = empty
				word1 = 0
				value$ = " \"\""
				hexValue$ = " EMPTY           "
			ELSE															' strip leading/trailing "
				IF (newValue${0} = '"') THEN
					newValue$ = MID$(newValue$, 2)
					newLen = UBOUND(newValue$)		' offset and new length, if applicable
					IF (newValue${newLen} = '"') THEN newValue$ = LEFT$(newValue$, newLen)
				END IF
				newValue$ = XstBackStringToBinString$ (@newValue$)
				value$ = XstBinStringToBackString$ (@newValue$)
				IF (LEN(value$) > 61) THEN
					value$ = " \"" + LEFT$(value$, 60) + "\"*"
				ELSE
					value$ = " \"" + value$ + "\""
				END IF

				word1 = &newValue$							' get address of new data
				handle = &&newValue$						' clear AUTOX handle so it isn't freed
				XLONGAT(handle) = 0
				hexValue$ = "@" + LJUST$(HEX$(word1, 8), 16)
			END IF

		CASE $$GIANT
			value$$ = GIANT(newValue$)
			word2 = GHIGH(value$$)
			word1 = GLOW(value$$)
			hexValue$ = " " + HEX$(word2, 8) + HEX$(word1, 8)
			value$ = STR$(value$$)

		CASE $$SINGLE
			value! = SINGLE(newValue$)
			word1 = XMAKE(value!)
			hexValue$ = " " + LJUST$(HEX$(word1, 8), 16)
			value$ = STR$(value!)

		CASE $$DOUBLE
			value# = DOUBLE(newValue$)
			word2 = DHIGH(value#)
			word1 = DLOW(value#)
			hexValue$ = " " + HEX$(word2, 8) + HEX$(word1, 8)
			value$ = STR$(value#)

		CASE $$GOADDR, $$SUBADDR, $$FUNCADDR
			SELECT CASE TRUE
				CASE (newValue${0} = '0')				' 0 or 0x...
					word1 = XLONG(newValue$)
					IFZ word1 THEN EXIT SELECT
					SELECT CASE tt
						CASE $$GOADDR, $$SUBADDR		' Must be inside exeFunction
							startAddr = funcFirstAddr[exeFunction]
							endAddr = funcAfterAddr[exeFunction] - 4
							IF (word1 < startAddr) THEN GOTO OutsideFunction
							IF (word1 > endAddr)   THEN GOTO OutsideFunction

						CASE ELSE															' Must be inside code space
							IF ((word1 >= ##CODE0)  AND (word1 <= ##CODEZ))  THEN EXIT SELECT
							IF ((word1 >= ##UCODE0) AND (word1 <= ##UCODEZ)) THEN EXIT SELECT
							GOTO OutsideCode
					END SELECT

				CASE ELSE
					SELECT CASE tt
						CASE $$GOADDR
							label$ = "%g%" + newValue$ + "%" + HEX$(exeFunction)
						CASE $$SUBADDR
							label$ = "%s%" + newValue$ + "%" + HEX$(exeFunction)
						CASE ELSE
							leftParen = INSTR(newValue$, "(")
							IF leftParen THEN
								label$ = "_" + LEFT$(newValue$, leftParen - 1)
							ELSE
								label$ = "_" + newValue$
							END IF
					END SELECT
					word1 = XxxGetAddressGivenLabel(label$)
					IFZ word1 THEN GOTO LabelNotFound
			END SELECT
			hexValue$ = " " + LJUST$(HEX$(word1, 8), 16)

'			convert back for redisplay...

			value$ = " " + HEXX$(word1, 8)			' addr if can't match label

			IF word1 THEN
				labels = XxxGetLabelGivenAddress (word1, @labels$[])
				IF (tt = $$FUNCADDR) THEN
					XxxPassFunctionArrays ($$XGET, @funcSymbol$[], @funcToken[],@funcScope[])
				END IF
				j = 0
				DO WHILE (j < labels)
					label$ = labels$[j]
					SELECT CASE tt
						CASE $$GOADDR							' %g%<user's GOTO label>%<HEX$(func#)>
							IF (LEFT$(label$, 3) = "%g%") THEN
								value$ = " " + MID$(label$, 4)
								ipercent = RINSTR(value$, "%")
								IF ipercent THEN value$ = LEFT$(value$, ipercent - 1)
								EXIT DO
							END IF
						CASE $$SUBADDR						' %s%<user's SUB label>%<func#>
							IF (LEFT$(label$, 3) = "%s%") THEN
								value$ = " " + MID$(label$, 4)
								ipercent = RINSTR(value$, "%")
								IF ipercent THEN value$ = LEFT$(value$, ipercent - 1)
								EXIT DO
							END IF
						CASE ELSE
							label$ = MID$(label$, 2)				' Strip leading _
							iat = RINSTR (label$, "@")			' Strip trailing @###
							IF iat THEN label$ = LEFT$(label$, iat - 1)
							FOR funcNumber = 0 TO maxFuncNumber
								IF funcSymbol$[funcNumber] THEN
									IF (label$ = funcSymbol$[funcNumber]) THEN
										value$ = " " + label$
										EXIT DO
									END IF
								END IF
							NEXT funcNumber
					END SELECT
					INC j
				LOOP
				IF (LEN(value$) > 64) THEN
					value$ = LEFT$(value$, 63) + "*"
				END IF
				IF (tt = $$FUNCADDR) THEN
					XxxPassFunctionArrays ($$XSET, @funcSymbol$[], @funcToken[],@funcScope[])
				END IF
			END IF

		CASE ELSE
			word1 = XLONG(newValue$)
			hexValue$ = " " + LJUST$(HEX$(word1, 8), 16)
			value$ = STR$(word1)

	END SELECT		' type

	IF varReg[index] THEN
'		Register offset:  varReg[index]		= register used (usually ebp)
'											varAddr[index]	= signed offset (eg -8)
		register = varReg[index]
		IF (register != 31) THEN GOTO InvalidRegister
		base		= variableFrame.frameAddr
		offset	= varAddr[index]
	ELSE
'		EXTERNAL
		base		= varAddr[index]
		offset	= 0
	END IF

	oldWord1 = XLONGAT(base, offset)
	XLONGAT(base, offset) = word1

	SELECT CASE tt
		CASE $$GIANT, $$DOUBLE
			offset = offset + 4
			XLONGAT(base, offset) = word2
	END SELECT

	IF (tt = $$STRING) THEN
		IF AddressOk(oldWord1) THEN
			IFZ (oldWord1 AND 3) THEN
'				infoWord = XLONGAT (oldWord1, -4)				' old alloc word 3
				infoWord = XLONGAT (oldWord1, -12)				' new alloc word 1
				IF (infoWord < 0) THEN free(oldWord1)
			END IF
		END IF
	END IF

	XuiSendMessage (variableBox, #GetTextArrayLine, index, 0, 0, 0, 3, @oldText$)
'	PRINT "Old text: '"; oldText$; "'"
	newText$ = LEFT$(oldText$, 44) + hexValue$ + " " + value$
	XuiSendMessage (variableBox, #SetTextArrayLine, index, 0, 0, 0, 3, @newText$)
	XuiSendMessage (variableBox, #SetTextCursor, 0, index, 0, 0, 3, 0)
	XuiSendMessage (variableBox, #RedrawText, 0, 0, 0, 0, 3, 0)
'	XuiSendMessage (variableBox, #GetTextArrayLine, index, 0, 0, 0, 3, @text$)
'	PRINT "New text: '"; text$; "'"

	message$ = ""																' Clear the new value box
	GOTO DisplayMessage
'
InvalidRegister:
	message$ = "New value invalid register:  " + reg86$[register]
	GOTO DisplayMessage
'
LabelNotFound:
	message$ = "New value label not found:  " + label$
	GOTO DisplayMessage
'
OutsideCode:
	message$ = "New value address not in code space:  " + label$
	GOTO DisplayMessage
'
OutsideFunction:
	message$ = "New value address outside current function:  " + label$
	GOTO DisplayMessage
'
UnsupportedType:
	message$ = "New value unsupported data type"
	GOTO DisplayMessage
'
SimpleTypesOnly:
	message$ = "New value for simple types only (use DETAIL for arrays, etc)"
'
DisplayMessage:
	XuiSendMessage (variableBox, #SetTextString, 0, 0, 0, 0, 7, @message$)
	XuiSendMessage (variableBox, #RedrawText, 0, 0, 0, 0, 7, 0)
END FUNCTION
'
'
' ################################
' #####  VariablesDetail ()  #####
' ################################
'
'	Respond to Variables Detail
'
'	Discussion:
'		NewValue and Detail both valid for STRING
'
FUNCTION  VariablesDetail ()
	SHARED  varTok[],  varSymbol$[],  varReg[],  varAddr[],  varTypes$[]
	SHARED  FRAMEINFO  variableFrame
	SHARED  reg86$[]
	SHARED  exeFunction
	SHARED  variableBox,  variableUp
	SHARED  arrayBox,  arrayUp,  arrayIndex
	SHARED  stringBox,  stringUp
	SHARED  stringSource,  stringSymbol$,  stringHandle$,  stringFixed
	SHARED  compositeBox,  compositeUp
	SHARED  compositeType,  compositeSymbol$,  compositeHandle$,  compositeElement$
'
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
'	who rang?
'
	XuiSendMessage (variableBox, #GetTextCursor, 0, @cursorLine, 0, 0, 3, 0)
	index = cursorLine
	token = varTok[index]
	tt = XxxTheType(token, exeFunction)
	kind = token{$$KIND}
'
	IF ((kind = $$KIND_ARRAYS) OR (tt = $$STRING) OR (tt >= 0x20)) THEN
		XuiSendMessage (variableBox, #SetTextString, 0, 0, 0, 0, 7, "")
		XuiSendMessage (variableBox, #RedrawText, 0, 0, 0, 0, 7, 0)
		arrayIndex = index
'
		IF (kind = $$KIND_ARRAYS) THEN
			VariablesArray (arrayBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
			RETURN
		END IF
'
'		location:  register offset ("ebp-8") or absolute address ("0xHHHHHHHH")
'
		IF varReg[index] THEN
'			Register offset:  varReg[index]		= register used (usually ebp)
'												varAddr[index]	= signed offset (eg -8)
			register = varReg[index]
			IF (register != 31) THEN
				Message (" VariablesDetail() \n\n invalid register " + reg86$[register] + " ")
				RETURN
			END IF
			base = variableFrame.frameAddr
			location$ = HEXX$(base + varAddr[index],8)
		ELSE
'			EXTERNAL
			location$ = HEXX$(varAddr[index],8)
		END IF
'
		SELECT CASE TRUE
			CASE (tt = $$STRING)										' string
				IF arrayUp THEN
					VariablesArray (arrayBox, #HideWindow, 0, 0, 0, 0, 0, 0)
				END IF
				IF compositeUp THEN
					VariablesComposite (compositeBox, #HideWindow, 0, 0, 0, 0, 0, 0)
				END IF
'
				stringSource = $$SourceVariables
				stringSymbol$ = varSymbol$[index]
				stringHandle$ = location$
				stringFixed	= 0												' not a FIXED STRING
				VariablesString (stringBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
			CASE ELSE																' composite
				IF arrayUp THEN
					VariablesArray (arrayBox, #HideWindow, 0, 0, 0, 0, 0, 0)
				END IF
				IF stringUp THEN
					VariablesString (stringBox, #HideWindow, 0, 0, 0, 0, 0, 0)
				END IF
'
				compositeType = tt
				compositeSymbol$ = varSymbol$[index]
				compositeHandle$ = location$
				compositeElement$ = ""
				VariablesComposite (compositeBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		END SELECT
	ELSE
		IF arrayUp THEN
			VariablesArray (arrayBox, #HideWindow, 0, 0, 0, 0, 0, 0)
		END IF
		IF stringUp THEN
			VariablesString (stringBox, #HideWindow, 0, 0, 0, 0, 0, 0)
		END IF
		IF compositeUp THEN
			VariablesComposite (compositeBox, #HideWindow, 0, 0, 0, 0, 0, 0)
		END IF
		error$ = "DETAIL valid for arrays, strings, composites only"
		XuiSendMessage (variableBox, #SetTextString, 0, 0, 0, 0, 7, @error$)
		XuiSendMessage (variableBox, #RedrawText, 0, 0, 0, 0, 7, 0)
	END IF
END FUNCTION
'
'
' ###############################
' #####  VariablesArray ()  #####
' ###############################
'
FUNCTION  VariablesArray (grid, message, v0, v1, v2, v3, r0, (r1, r1$))
	SHARED  arrayUp
'
	$functionLabel	= 1
	$symbolLabel		= 2
	$columnLabel		= 3
	$list						= 4
	$higherButton		= 5
	$lowerButton		= 6
	$indexLabel			= 7
	$indexText			= 8
	$elementLabel		= 9
	$elementText		= 10
	$button0				= 11
	$button1				= 12
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow
		CASE #HideWindow		: GOSUB HideWindow
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: GOSUB HideWindow
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****
'
SUB DisplayWindow
	VariablesArrayDisplay (0)
	XuiSendMessage (grid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
	arrayUp = $$TRUE
END SUB
'
'
' *****  HideWindow  *****
'
SUB HideWindow
	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
	arrayUp = $$FALSE
END SUB
'
'
' *****  Selection  *****
'
SUB Selection
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
	SELECT CASE r0
		CASE $higherButton	:	VariablesArrayDisplay (2)
		CASE $lowerButton		:	VariablesArrayDisplay (1)
		CASE $button0				:	VariablesArrayDetail ()
		CASE $button1				:	GOSUB HideWindow
		CASE $indexText
			IF (v0{$$VirtualKey} = $$KeyEscape) THEN
				GOSUB HideWindow
			ELSE
				VariablesArrayIndex ()
			END IF
		CASE $elementText
			IF (v0{$$VirtualKey} = $$KeyEscape) THEN
				GOSUB HideWindow
			ELSE
				VariablesArrayElement ()
			END IF
	END SELECT
END SUB
END FUNCTION
'
'
' ######################################
' #####  VariablesArrayDisplay ()  #####
' ######################################
'
'	Control the Array box based on the action requested
'
'	In:		action =	0	- display new symbol
'									1 - step down
'									2 - step up
'									3 - View element (from ArrayElement)
'									4 - Redisplay
'
FUNCTION  VariablesArrayDisplay (action)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  varTok[],  varSymbol$[],  varReg[],  varAddr[],  varDataAddr[]
	SHARED  varTypes$[]
	SHARED  funcFirstAddr[],  funcAfterAddr[]
	SHARED  exeFunction,  exeLine
	SHARED  arrayBox,  arrayUp
	SHARED  arrayIndex,  arrayHandle
	SHARED  arrayViewIndices[],  arrayNumViewIndices
	STATIC  arrayLevel,  arrayIndices[]
	STATIC  lastFunction,  lastLine
	AUTOX  copyString$
'
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
	IF ((arrayUp = $$FALSE) OR (lastFunction != exeFunction) OR (lastLine != exeLine)) THEN
		XxxFunctionName ($$XGET, @funcName$, exeFunction)
		IF (LEN(funcName$) > 30) THEN funcName$ = LEFT$(funcName$, 29) + "*"
		label$ = "FUNCTION:    " + funcName$ + "    LINE:  " + STRING$(exeLine)
		XuiSendMessage (arrayBox, #SetTextString, 0, 0, 0, 0, 1, @label$)
		XuiSendMessage (arrayBox, #RedrawGrid, 0, 0, 0, 0, 1, 0)
		lastFunction = exeFunction
		lastLine = exeLine
	END IF
'
	XuiSendMessage (arrayBox, #GetTextCursor, 0, @cursorLine, 0, 0, 4, 0)
'
	cursorIndex = 0													' default: cursor on first line
	SELECT CASE action
		CASE 0																' display top level
			arrayLevel = 0
			DIM arrayIndices[7]
		CASE 1																' step down
			stepDownIndex = cursorLine
		CASE 2																' step up
			IF arrayLevel THEN
				arrayIndices[arrayLevel] = 0
				DEC arrayLevel
				cursorIndex = arrayIndices[arrayLevel]
			END IF
		CASE 3																' View Element
			arrayLevel = 0											' Reset array level info
			DIM arrayIndices[7]
'			cursorIndex = arrayViewIndices[0]
		CASE 4																' Redisplay
			cursorIndex = cursorLine
	END SELECT

	tt = XxxTheType (varTok[arrayIndex], exeFunction)
	type$ = TRIM$(varTypes$[tt])						' guaranteed valid type
	symbol$ = varSymbol$[arrayIndex]
	symbol$ = RCLIP$(symbol$, 1)						' strip ] for now

	dataAddr = varDataAddr[arrayIndex]
	level = 0
	DO WHILE (level <= arrayLevel)
		IFZ dataAddr THEN
			IFZ notLowDim THEN
				symbol$ = symbol$ + "]"
			ELSE
				symbol$ = symbol$ + ",]"
			END IF
			label$ = type$ + "  " + symbol$
			XuiSendMessage (arrayBox, #SetTextString, 0, 0, 0, 0, 2, @label$)
			XuiSendMessage (arrayBox, #RedrawGrid, 0, 0, 0, 0, 2, 0)
			viewLabel$ = LJUST$("View Index []", 27)
			XuiSendMessage (arrayBox, #SetTextString, 0, 0, 0, 0, 7, @viewLabel$)
			XuiSendMessage (arrayBox, #RedrawGrid, 0, 0, 0, 0, 7, 0)
			DIM text$[0]
			text$[0] = "EMPTY array"
			XuiSendMessage (arrayBox, #SetTextArray, 0, 0, 0, 0, 4, @text$[])
			XuiSendMessage (arrayBox, #SetTextCursor, 0, 0, 0, 0, 4, 0)
			XuiSendMessage (arrayBox, #RedrawText, 0, 0, 0, 0, 4, 0)
			RETURN
		END IF
		headerAddr = dataAddr - 0x10
		elements = XLONGAT(headerAddr, [2])
		infoWord = XLONGAT(headerAddr, [3])
		eleSize = infoWord{$$ELESIZE}
'
'		infoWord:  bit 29 = NON-LOW-DIM  (1 = non-low-dim, 0 = lowest dimension)
'							 Byte 2 = Data Type  (0 - 0xFF)
'											= 0x1F means composite user Data type number exceeds 0xFF
'													(problem if user ATTACHes a different composite to
'														a node where both type numbers exceed 0xFF.
'														If the info word eleSize is different than the
'														array type eleSize, then I KNOW an ATTACH has been
'														done.  Otherwise, interpret the data as the same
'														type, but issue the user a warning.)
'
		notLowDim = infoWord{{$$NOT_LOWEST_DIM}}
		dataType = infoWord{$$BYTE2}
'
		IF (level = arrayLevel) THEN
			IF (action = 1) THEN										' step down
				IF notLowDim THEN											' only if not lowest Dim
					uArray = UBOUND(arrayIndices[])
					IF (arrayLevel >= uArray) THEN
						uArray = arrayLevel + (arrayLevel >> 1)
						REDIM arrayIndices[uArray]
					END IF
					arrayIndices[arrayLevel] = stepDownIndex
					INC arrayLevel
					offset = stepDownIndex * eleSize
					dataAddr = XLONGAT(dataAddr, offset)
					IFZ level THEN
						symbol$ = symbol$ + STRING$(stepDownIndex)
					ELSE
						symbol$ = symbol$ + "," + STRING$(stepDownIndex)
					END IF
					INC level
					action = 0
					DO DO
				END IF
			END IF

			IF (action = 3) THEN										' View Element
				IF notLowDim THEN											' keep going only if more Dims
					IF (arrayNumViewIndices > arrayLevel) THEN
						uArray = UBOUND(arrayIndices[])
						IF (arrayLevel >= uArray) THEN
							uArray = arrayLevel + (arrayLevel >> 1)
							REDIM arrayIndices[uArray]
						END IF
						index = arrayViewIndices[arrayLevel]
						IF (index > elements - 1) THEN		' requested index is out of bounds
							index = elements - 1						'		stop here
							arrayNumViewIndices = arrayLevel + 1
						END IF
						arrayIndices[arrayLevel] = index
						INC arrayLevel
						offset = index * eleSize
						dataAddr = XLONGAT(dataAddr, offset)
						IFZ dataAddr THEN									' Empty node, stop here
							arrayNumViewIndices = arrayLevel + 1
						END IF
						IFZ level THEN
							symbol$ = symbol$ + STRING$(index)
						ELSE
							symbol$ = symbol$ + "," + STRING$(index)
						END IF
						INC level
						DO DO
					END IF
				END IF
			END IF

			IFZ notLowDim THEN												' low dim
				IFZ level THEN
					symbol$ = symbol$ + "i]"
				ELSE
					symbol$ = symbol$ + ",i]"
				END IF
				IF (dataType != tt) THEN								' node may be a dIfferent type
					IF (dataType != 0x1F) THEN						' identifiable type in info word
						tt = dataType
						type$ = TRIM$(varTypes$[tt])
						statusComposite = 1
					ELSE																	' info word is unknown composite
'						Default: unsure if same composite
						statusComposite = 2
						IF (tt <= 0xFF) THEN								' array type is known
'							Array type is known, info type isn't:  definitely a different type
							statusComposite = 3
							type$ = "??? "
						ELSE
'							If array size != info size:  definitely a different type

'							Get size of array element

			XxxPassTypeArrays ($$XGET, @pSize[], @pSize$[], @pAlias[], @pAlign[], @pSymbol$[], @pToken[], @pEleCount[], @pEleSymbol$[], @pEleToken[], @pEleAddr[], @pEleSize[], @pEleType[], @pEleStringSize[], @pEleUBound[])
			typeSize = pSize[tt]
			XxxPassTypeArrays ($$XSET, @pSize[], @pSize$[], @pAlias[], @pAlign[], @pSymbol$[], @pToken[], @pEleCount[], @pEleSymbol$[], @pEleToken[], @pEleAddr[], @pEleSize[], @pEleType[], @pEleStringSize[], @pEleUBound[])

'							Get size of this node's element
							infoSize = infoWord{$$WORD0}

							IF (infoSize != typeSize) THEN
								statusComposite = 3
								type$ = "??? "
							END IF
						END IF
					END IF
				END IF
			ELSE																			' not low dim
				IFZ level THEN
					symbol$ = symbol$ + "i,]"
				ELSE
					symbol$ = symbol$ + ",i,]"
				END IF
				tt = $$XLONG
			END IF
			EXIT DO
		END IF

		nextIndex = arrayIndices[level]							' get next level dataAddr
		offset = nextIndex * eleSize
		dataAddr = XLONGAT(dataAddr, offset)
		IFZ level THEN
			symbol$ = symbol$ + STRING$(nextIndex)
		ELSE
			symbol$ = symbol$ + "," + STRING$(nextIndex)
		END IF
		INC level
	LOOP
'
'	Maybe display dataAddr (base array address) as label
'   - maybe UBOUND, handle...
'
	label$ = type$ + "  " + symbol$
	XuiSendMessage (arrayBox, #GetTextString, 0, 0, 0, 0, 2, @oldLabel$)
	IF (label$ != oldLabel$) THEN
		XuiSendMessage (arrayBox, #SetTextString, 0, 0, 0, 0, 2, @label$)
		XuiSendMessage (arrayBox, #RedrawGrid, 0, 0, 0, 0, 2, 0)
	END IF

	lastElement = elements - 1
	label$ = LJUST$("View Index [0-" + STRING$(lastElement) + "]", 27)
	XuiSendMessage (arrayBox, #GetTextString, 0, 0, 0, 0, 7, @oldLabel$)
	IF (label$ != oldLabel$) THEN
		XuiSendMessage (arrayBox, #SetTextString, 0, 0, 0, 0, 7, @label$)
		XuiSendMessage (arrayBox, #RedrawGrid, 0, 0, 0, 0, 7, 0)
	END IF

	DIM arrayText$[lastElement]
	indexAddr = dataAddr
	FOR index = 0 TO lastElement
		index$ = LJUST$(STRING$(index), 10)
		loc$ = HEX$(indexAddr, 8)

		IF notLowDim THEN
			word1 = XLONGAT(indexAddr)
			IFZ word1 THEN
				arrayText$[index] = index$ + " " + loc$ + "    EMPTY"
			ELSE
				arrayText$[index] = index$ + " " + loc$ + "    @" + HEX$(word1, 8)
			END IF
		ELSE
			SELECT CASE tt
				CASE $$GIANT, $$DOUBLE
					word1 = XLONGAT(indexAddr)
					word2 = XLONGAT(indexAddr, [1])
					hexValue$ = " " + HEX$(word2, 8) + HEX$(word1, 8)
				CASE $$SBYTE
					word1 = SBYTEAT(indexAddr)
					hexValue$ = " " + HEX$(word1, 2) + "              "
				CASE $$UBYTE
					word1 = UBYTEAT(indexAddr)
					hexValue$ = " " + HEX$(word1, 2) + "              "
				CASE $$SSHORT
					word1 = SSHORTAT(indexAddr)
					hexValue$ = " " + HEX$(word1, 4) + "            "
				CASE $$USHORT
					word1 = USHORTAT(indexAddr)
					hexValue$ = " " + HEX$(word1, 4) + "            "
				CASE ELSE
					word1 = XLONGAT(indexAddr)
					hexValue$ = " " + HEX$(word1, 8) + "        "
			END SELECT

			SELECT CASE TRUE
				CASE (tt >= 0x20)											' composite
					SELECT CASE statusComposite
						CASE 3:			hexValue$ = " unknown type    "
						CASE 2:			hexValue$ = " maybe diff type "
						CASE 1:			hexValue$ = " different type  "
						CASE ELSE:	hexValue$ = "                 "
					END SELECT
					value$ = " <composite>"
				CASE (tt = $$STRING)
					copyString$ = ""										' make a copy of word1 string
					handle = &&copyString$
					XLONGAT (handle) = word1
					value$ = LEFT$(copyString$, 61)
					XLONGAT (handle) = 0								' but don't free word1
					value$ = XstBinStringToBackString$ (@value$)	' encode non-printables
					IF (LEN(value$) > 61) THEN
						value$ = " \"" + LEFT$(value$, 60) + "\"*"
					ELSE
						value$ = " \"" + value$ + "\""
					END IF
					IFZ word1 THEN
						hexValue$ = LJUST$(" EMPTY", 17)
					ELSE
						hexValue$ = "@" + HEX$(word1, 8) + "        "
					END IF
				CASE (tt = $$GIANT)
					value$$ = GMAKE(word2, word1)
					value$ = STR$(value$$)
				CASE (tt = $$SINGLE)
					value! = SMAKE(word1)
					value$ = STR$(value!)
				CASE (tt = $$DOUBLE)
					value# = DMAKE(word2, word1)
					value$ = STR$(value#)
				CASE (tt = $$GOADDR), (tt = $$SUBADDR), (tt = $$FUNCADDR)
					value$ = " " + HEXX$(word1, 8)			' addr if can't match label
					hexValue$ = "@" + HEX$(word1, 8) + "        "

					labels = XxxGetLabelGivenAddress (word1, @labels$[])
					IF (tt = $$FUNCADDR) THEN
						XxxPassFunctionArrays ($$XGET, @funcSymbol$[], @funcToken[], @funcScope[])
					END IF
					j = 0
					DO WHILE (j < labels)
						label$ = labels$[j]
						SELECT CASE tt
							CASE $$GOADDR				' %g%<user's GOTO label>%<func#>
								IF (LEFT$(label$, 3) = "%g%") THEN
									value$ = " " + MID$(label$, 4)
									ipercent = RINSTR(value$, "%")
									IF ipercent THEN value$ = LEFT$(value$, ipercent - 1)
									EXIT DO
								END IF
							CASE $$SUBADDR				' %s%<user's SUB label>%<func#>
								IF (LEFT$(label$, 3) = "%s%") THEN
									value$ = " " + MID$(label$, 4)
									ipercent = RINSTR(value$, "%")
									IF ipercent THEN value$ = LEFT$(value$, ipercent - 1)
									EXIT DO
								END IF
							CASE ELSE
								label$ = MID$(label$, 2)				' Strip leading _
								iat = RINSTR (label$, "@")			' Strip trailing @###
								IF iat THEN label$ = LEFT$(label$, iat - 1)
								FOR funcNumber = 0 TO maxFuncNumber
									IF funcSymbol$[funcNumber] THEN
										IF (label$ = funcSymbol$[funcNumber]) THEN
											value$ = " " + label$
											EXIT DO
										END IF
									END IF
								NEXT funcNumber
						END SELECT
						INC j
					LOOP
					IF (LEN(value$) > 64) THEN
						value$ = LEFT$(value$, 63) + "*"
					END IF
					IF (tt = $$FUNCADDR) THEN
						XxxPassFunctionArrays ($$XSET, @funcSymbol$[], @funcToken[], @funcScope[])
					END IF

				CASE (tt = $$ULONG)
					value$ = STR$(ULONG(word1))

				CASE ELSE
					value$ = STR$(word1)
			END SELECT
			arrayText$[index] = index$ + " " + loc$ + "    " + hexValue$ + " " + value$
		END IF		' notLowDim

		indexAddr = indexAddr + eleSize
	NEXT index
	XuiSendMessage (arrayBox, #SetTextArray, 0, 0, 0, 0, 4, @arrayText$[])
	XuiSendMessage (arrayBox, #SetTextCursor, 0, cursorIndex, 0, 0, 4, 0)
	XuiSendMessage (arrayBox, #RedrawText, 0, 0, 0, 0, 4, 0)
END FUNCTION
'
'
' ####################################
' #####  VariablesArrayIndex ()  #####
' ####################################
'
'	View the requested array index in the Array box
'
FUNCTION  VariablesArrayIndex ()
	SHARED  arrayBox
'
' Get the requested index
'
	XuiSendMessage (arrayBox, #GetTextString, 0, 0, 0, 0, 8, @index$)
	XuiSendMessage (arrayBox, #SetTextString, 0, 0, 0, 0, 8, "")
	XuiSendMessage (arrayBox, #RedrawText, 0, 0, 0, 0, 8, 0)
'
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
	index$ = TRIM$(index$)
	index# = DOUBLE(index$)
	SELECT CASE TRUE
		CASE (index# < 0):					index = 0
		CASE (index# > 0x7FFFFFFF):	index = 0x7FFFFFFF
		CASE ELSE:									index = index#
	END SELECT
'
	XuiSendMessage (arrayBox, #SetTextCursor, 0, index, -1, 0, 4, 0)
	XuiSendMessage (arrayBox, #RedrawText, 0, 0, 0, 0, 4, 0)
END FUNCTION
'
'
' ######################################
' #####  VariablesArrayElement ()  #####
' ######################################
'
'	Display the requested array element ([1,2,3,]) in the Array box
'
'	Discussion:
'		Should this display 'Syntax Error'?  (currently just returns)
'
FUNCTION  VariablesArrayElement ()
	SHARED  arrayBox
	SHARED  arrayViewIndices[],  arrayNumViewIndices
'
' Get the requested element
'
	XuiSendMessage (arrayBox, #GetTextString, 0, 0, 0, 0, 10, @rawElement$)
	XuiSendMessage (arrayBox, #SetTextString, 0, 0, 0, 0, 10, "")
	XuiSendMessage (arrayBox, #RedrawText, 0, 0, 0, 0, 10, 0)
'
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
	rawElement$ = TRIM$(rawElement$)
	IFZ rawElement$ THEN
		VariablesArrayDisplay (0)
		RETURN
	END IF

'	Clean up syntax (keep only 0-9 and ,)
	lenRawElement = LEN(rawElement$)
	element$ = NULL$ (lenRawElement)
	j = 0
	FOR i = 0 TO (lenRawElement - 1)
		cchar = rawElement${i}
		IF ( ((cchar >= '0') AND (cchar <= '9')) OR (cchar = ',')) THEN
			element${j} = cchar
			INC j
		ELSE
			IF (cchar = ' ') THEN DO NEXT
			IF ((i = 0) AND (cchar = '[')) THEN DO NEXT
			IF ((i = lenRawElement - 1) AND (cchar = ']')) THEN DO NEXT
			RETURN																' Syntax error
		END IF
	NEXT i
	IFZ j THEN RETURN
	IF (element${0} = ',') THEN RETURN				' Syntax error
	IF INSTR(element$, ",,") THEN RETURN			' Syntax error
'
	lenElement = j
	arrayNumViewIndices = 0
	uArray = UBOUND(arrayViewIndices[])
	ptr = 1
'
	DO WHILE (ptr <= lenElement)
		index# = DOUBLE(MID$(element$, ptr))
		SELECT CASE TRUE
			CASE (index# < 0):					index = 0
			CASE (index# > 0x7FFFFFFF):	index = 0x7FFFFFFF
			CASE ELSE:									index = index#
		END SELECT
'
		IF (arrayNumViewIndices > uArray) THEN
			uArray = (uArray + (uArray >> 1)) OR 3
			REDIM arrayViewIndices[uArray]
		END IF
		arrayViewIndices[arrayNumViewIndices] = index
		INC arrayNumViewIndices
'
		comma = INSTR(element$, ",", ptr)
		IFZ comma THEN EXIT DO
		ptr = comma + 1
	LOOP
	VariablesArrayDisplay (3)
END FUNCTION
'
'
' #####################################
' #####  VariablesArrayDetail ()  #####
' #####################################
'
'	Show detail on composite or STRING array element
'
FUNCTION  VariablesArrayDetail ()
	SHARED  varTypes$[]
	SHARED  arrayBox,  stringBox,  compositeBox
	SHARED  stringSource,  stringSymbol$,  stringHandle$,  stringFixed
	SHARED  compositeType,  compositeSymbol$,  compositeHandle$,  compositeElement$
	STATIC  arrayCompositeHandle
'
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
'	Symbol label
'
	XuiSendMessage (arrayBox, #GetTextString, 0, 0, 0, 0, 2, @label$)
'
'	Detail on lowest dimension only
'
	last2$ = RIGHT$(label$, 2)
	IF (last2$ = ",]") THEN RETURN							' not lowest dimension
	IF (last2$ != "i]") THEN RETURN			' huh???
'
'	Identify the type
'
	sp = INSTR (label$, " ")
	IFZ sp THEN RETURN													' unknown type
	type$ = LEFT$(label$, sp - 1)
	symbol$ = TRIM$(MID$(label$, sp))

	uType = UBOUND (varTypes$[])
	FOR i = 0 TO uType
		IF (type$ = TRIM$(varTypes$[i])) THEN
			tt = i
			EXIT FOR
		END IF
	NEXT i
'
	IFZ tt THEN RETURN													' unknown type
'
'	Detail on STRING and composite only
'
	IF ((tt != $$STRING) AND (tt < 0x20)) THEN
		RETURN																		' no detail on this type
	END IF
'
'	Get requested line
'
	XuiSendMessage (arrayBox, #GetTextCursor, 0, @cursorLine, 0, 0, 4, 0)
	IF (cursorLine < 0) THEN RETURN
	XuiSendMessage (arrayBox, #GetTextArrayLine, @cursorLine, 0, 0, 0, 4, @line$)
'
'	Get index (column 1)
'
	sp = INSTR (line$, " ")
	index$ = LEFT$(line$, sp - 1)
	IF (index$ = "EMPTY") THEN RETURN						' "empty array"
	symbol$ = RCLIP$(symbol$, 2) + index$ + "]"	' specify index in symbol$
'
'	Get Location (column 12)
'
	sp = INSTR (line$, " ", 12)
	location$ = "0x" + MID$(line$, 12, sp - 12)
	location = XLONG (location$)
	IFZ location THEN RETURN										' shouldn't happen

	IF (tt = $$STRING) THEN											' string
		stringSource = $$SourceArrays
		stringSymbol$ = symbol$
		stringHandle$ = location$
		stringFixed = 0														' not a FIXED STRING
		VariablesString (stringBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
	ELSE																				' composite
		compositeType = tt
		compositeSymbol$ = symbol$
'
'		location points to the DATA, need a fake handle
'
		arrayCompositeHandle = location
		compositeHandle$ = HEXX$(&arrayCompositeHandle, 8)
		compositeElement$ = ""
		VariablesComposite (compositeBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
	END IF
END FUNCTION
'
'
' ################################
' #####  VariablesString ()  #####
' ################################
'
'	Give detail on the specified string
'
'	Discussion:
'		stringSymbol$, stringHandle$ contain the symbol and handle to work with
'
FUNCTION  VariablesString (grid, message, v0, v1, v2, v3, r0, r1)
	SHARED  exeFunction,  exeLine
	SHARED  stringUp,  stringBox,  compositeBox
	SHARED  stringSource,  stringSymbol$,  stringHandle$,  stringFixed
	STATIC  stringBackMode
	AUTOX  text$
'
	$functionLabel	= 1
	$symbolLabel		= 2
	$textArea				= 3
	$toggle					= 4
	$button0				= 5
	$button1				= 6
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow
		CASE #HideWindow		: GOSUB HideWindow
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: GOSUB HideWindow
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****  'grid' unused : stringHandle$ (NOT text) is used to enable alteration
'
SUB DisplayWindow
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
	XxxFunctionName ($$XGET, @funcName$, exeFunction)
	IF (LEN(funcName$) > 30) THEN funcName$ = LEFT$(funcName$, 29) + "*"
	label$ = "FUNCTION:    " + funcName$ + "    LINE:  " + STRING$(exeLine)
	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $functionLabel, @label$)
	XuiSendMessage (grid, #RedrawGrid, 0, 0, 0, 0, $functionLabel, 0)
	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $symbolLabel, @stringSymbol$)
	XuiSendMessage (grid, #RedrawGrid, 0, 0, 0, 0, $symbolLabel, 0)
'
' get the string data
'
	IF stringFixed THEN
		textAddr = XLONG (stringHandle$)						' actually, data address
	ELSE
		IF (stringHandle${0} = 'r') THEN						' handle is a register
			register = XLONG (MID$(stringHandle$, 2))	'		guaranteed valid register
'			textAddr = ##REG[register]
		ELSE																				' specific address (0x...)
			handleAddr = XLONG (stringHandle$)
			textAddr = XLONGAT (handleAddr)
		END IF
	END IF
'
'	PRINT "String:  '"; stringHandle$; "'", HEXX$(textAddr)
'
' make a copy
'
	text$ = ""
	IF stringFixed THEN														' composite Fixed String = data address
		text$ = NULL$ (stringFixed + 1)							' copy original text, add EMPTY
		FOR i = 0 TO (stringFixed - 1)
			text${i} = UBYTEAT(textAddr, i)
		NEXT i
	ELSE
		IF textAddr THEN
			lenText = XLONGAT (textAddr, -8)
			IF lenText THEN
				text$ = NULL$ (lenText)									' copy original text
				FOR i = 0 TO lenText - 1
					text${i} = UBYTEAT (textAddr, i)
				NEXT i
			END IF
		END IF
	END IF
'
	IF stringBackMode THEN text$ = XstBinStringToBackStringNL$ (@text$)
	XstStringToStringArray (@text$, @text$[])
'
'	PRINT "Detail String '"; text$; "'"
'	PRINT "Detail Array:"
'	FOR i = 0 TO UBOUND(text$[])
'		PRINT "  "; i; "'"; text$[i]; "'"
'	NEXT i
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $textArea, @text$[])
	XuiSendMessage (grid, #SetTextCursor, 0, 0, 0, 0, $textArea, 0)
	XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textArea, 0)
	XuiSendMessage (grid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
	stringUp = $$TRUE
END SUB
'
'
' *****  HideWindow  *****
'
SUB HideWindow
	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
	stringUp = $$FALSE
END SUB
'
'
' *****  Selection  *****
'
SUB Selection
	SELECT CASE r0
		CASE $toggle	:	XuiSendMessage (grid, #GetValues, @newMode, 0, 0, 0, $toggle, 0)
										GOSUB NewStringMode
		CASE $button0	:	GOSUB NewStringValue
		CASE $button1	:	GOSUB HideWindow
	END SELECT
END SUB
'
'
' *****  NewStringMode  *****  Convert detail string from binary to back
'
SUB NewStringMode
	IF (newMode = stringBackMode) THEN EXIT SUB
	stringBackMode = newMode
	XuiSendMessage (grid, #GetTextArray, 0, 0, 0, 0, $textArea, @text$[])
	XuiSendMessage (grid, #GetTextCursor, 0, @cursorLine, 0, @topLine, $textArea, 0)
	IFZ text$[] THEN EXIT SUB
	XstStringArrayToString (@text$[], @text$)		' No CRLF
	IF stringBackMode THEN											' Convert from bin to back
		text$ = XstBinStringToBackStringNL$ (@text$)		' leave \n
	ELSE																				' Convert from back to bin
		text$ = XstBackStringToBinString$ (@text$)
	END IF
	XstStringToStringArray (@text$, @text$[])
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $textArea, @text$[])
	XuiSendMessage (grid, #SetTextCursor, 0, cursorLine, 0, topLine, $textArea, 0)
	XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $textArea, 0)
END SUB
'
'
' *****  NewStringValue  *****
'		Replace displayed detail string with current text
'			- Uses handle to replace the original string data!
'
SUB NewStringValue
	XuiSendMessage (grid, #GetTextArray, 0, 0, 0, 0, $textArea, @text$[])
	text$ = ""
	IF text$[] THEN
		XstStringArrayToString (@text$[], @text$)		' No CRLF
		IF stringBackMode THEN											' Convert from back to bin
			text$ = XstBackStringToBinString$ (@text$)
		END IF
	END IF
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, $textArea, @text$[])
	XuiSendMessage (grid, #SetTextCursor, 0, 0, 0, 0, $textArea, 0)
'	PRINT "NewValue$: '"; text$; "'"

	IF stringFixed THEN														' stringFixed = size
		text$ = LJUST$(text$, stringFixed)					' pad/truncate with spaces
		oldTextAddr = XLONG (stringHandle$)					' actually, fixed data address
		FOR i = 0 TO (stringFixed - 1)
			UBYTEAT (oldTextAddr, i) = text${i}
		NEXT i
	ELSE
		IF (stringHandle${0} = 'r') THEN						' handle is a register
			register = XLONG (MID$(stringHandle$, 2))	'		guaranteed valid register
'			oldTextAddr = ##REG[register]
'			IF oldTextAddr THEN free (oldTextAddr)
'			##REG[register] = &text$
		ELSE																				' specific address (0x...)
			handleAddr = XLONG (stringHandle$)
			oldTextAddr = XLONGAT (handleAddr)
			IF oldTextAddr THEN free (oldTextAddr)
			XLONGAT (handleAddr) = &text$
		END IF
		textHandle = &&text$												' don't free text$
		XLONGAT(textHandle) = 0
	END IF

	SELECT CASE stringSource											' update displays
		CASE $$SourceVariables	: UpdateVariables()
		CASE $$SourceArrays			: VariablesArrayDisplay (4)
		CASE $$SourceComposites	: VariablesComposite (compositeBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
	END SELECT
END SUB
END FUNCTION
'
'
' ###################################
' #####  VariablesComposite ()  #####
' ###################################
'
FUNCTION  VariablesComposite (grid, message, v0, v1, v2, v3, r0, r1)
	SHARED  compositeElement$
	SHARED  compositeBox
'
	$functionLabel	=  1
	$symbolLabel		=  2
	$columnLabel		=  3
	$list						=  4
	$higherButton		=  5
	$lowerButton		=  6
	$viewLabel			=  7
	$viewText				=  8
	$button0				=  9
	$button1				= 10
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow
		CASE #HideWindow		: GOSUB HideWindow
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: GOSUB HideWindow
		CASE #Selection			:	GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****
'
SUB DisplayWindow
	VariablesCompositeDisplay (0)
	XuiSendMessage (grid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
	compositeUp = $$TRUE
END SUB
'
'
' *****  HideWindow  *****
'
SUB HideWindow
'	PRINT "VariablesComposite() : HideWindow : "; grid; compositeBox; #HideWindow
	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
	compositeUp = $$FALSE
END SUB
'
'
' *****  Selection  *****
'
SUB Selection
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		SELECT CASE r0
			CASE $button1		: GOSUB HideWindow
			CASE $viewText	: IF (v0{$$VirtualKey} = $$KeyEscape) THEN GOSUB HideWindow
		END SELECT
		RETURN
	END IF
'
	SELECT CASE r0
		CASE $higherButton	:	VariablesCompositeDisplay (2)
		CASE $lowerButton		:	VariablesCompositeDisplay (1)
		CASE $button0				:	VariablesCompositeDisplay (3)
		CASE $button1				:	GOSUB HideWindow
		CASE $viewText
			IF (v0{$$VirtualKey} = $$KeyEscape) THEN
				GOSUB HideWindow
			ELSE
				XuiSendMessage (grid, #GetTextString, 0, 0, 0, 0, $viewText, @compositeElement$)
				XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, $viewText, "")
				XuiSendMessage (grid, #RedrawText, 0, 0, 0, 0, $viewText, 0)
				VariablesCompositeDisplay (0)
			END IF
	END SELECT
END SUB
END FUNCTION
'
'
' ##########################################
' #####  VariablesCompositeDisplay ()  #####
' ##########################################
'
'	Display detail on a composite variable in the Composite box
'
'	In:				action		0	- display element
'											1 - step down
'											2 - step up
'											3 - Detail (fixed STRINGs only)
'	Discussion:
'		The type arrays (from the compiler):
'		typeName$					[type]			' "sbyte", "ubyte"...
'		typeSize					[type]			' size in bytes
'		typeSize$					[type]			' "2", "4", "8", "16"...
'		typeAlias					[type]			' normal type that user-type is alias for
'		typeAlign					[type]			' alignment for this type
'		typeSuffix$				[type]			' @  @@  %  %%  &  &&  ~  !  #  $$  $
'		typeSymbol$				[type]			' SBYTE, UBYTE...  SCOMPLEX, DCOMPLEX, USERTYPE...
'		typeToken					[type]			' T_TYPE token, low word = type #
'		typeEleCount			[type]			' # of elements in this type
'		typeEleSymbol$		[type,n]		' symbol for each n elements
'		typeEleToken			[type,n]		' token for each n elements
'		typeEleAddr				[type,n]		' offset address of each n elements
'		typeEleSize				[type,n]		' size of each n elements ([]: typesize*(dim+1))
'		typeEleType				[type,n]		' type of each n elements
'		typeElePtr				[type,n]		' # indirection levels for each n elements
'		typeEleVal				[type,n]		' init value of each n elements
'		typeEleStringSize	[type,n]		' # bytes in fixed string for element n
'		typeEleUBound			[type,n]		' Upper bound of 1D array for element n
'
FUNCTION  VariablesCompositeDisplay (action)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  varTypes$[]
	SHARED  exeFunction,  exeLine
	SHARED  compositeBox,  compositeUp
	SHARED  compositeType,  compositeSymbol$,  compositeHandle$,  compositeElement$
	SHARED  stringBox,  stringSource,  stringSymbol$,  stringHandle$,  stringFixed
	STATIC  lastFunction,  lastLine
'
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
	IF ((compositeUp = $$FALSE) OR (lastFunction != exeFunction) OR (lastLine != exeLine)) THEN
		XxxFunctionName ($$XGET, @funcName$, exeFunction)
		IF (LEN(funcName$) > 30) THEN funcName$ = LEFT$(funcName$, 29) + "*"
		label$ = "FUNCTION:    " + funcName$ + "    LINE:  " + STRING$(exeLine)
		XuiSendMessage (compositeBox, #SetTextString, 0, 0, 0, 0, 1, @label$)
		XuiSendMessage (compositeBox, #RedrawGrid, 0, 0, 0, 0, 1, 0)
		lastFunction = exeFunction
		lastLine = exeLine
	END IF
	XuiSendMessage (compositeBox, #SetTextString, 0, 0, 0, 0, 2, @compositeSymbol$)
	XuiSendMessage (compositeBox, #RedrawGrid, 0, 0, 0, 0, 2, 0)
'
'	Get the composite data address
'		composite data is always contiguous--no composite pointers
'
	IF (compositeHandle${0} = 'r') THEN							' handle is a register
		register = XLONG (MID$(compositeHandle$, 2))	'		guaranteed valid register
'		dataAddr = ##REG[register]
	ELSE																						' specific address (0x...)
		handleAddr = XLONG(compositeHandle$)
		dataAddr = XLONGAT(handleAddr)
	END IF
'
	IFZ dataAddr THEN
		DIM text$[0]
		text$[0] = "EMPTY"
		XuiSendMessage (compositeBox, #SetTextArray, 0, 0, 0, 0, 4, @text$[])
		XuiSendMessage (compositeBox, #SetTextCursor, 0, 0, 0, 0, 4, 0)
		XuiSendMessage (compositeBox, #RedrawText, 0, 0, 0, 0, 4, 0)
		RETURN
	END IF
'
	SELECT CASE action
		CASE 1																' step down
			XuiSendMessage (compositeBox, #GetTextCursor, 0, @cursorLine, 0, 0, 4, 0)
			stepDownIndex = cursorLine
		CASE 2																' step up
			IF compositeElement$ THEN
				IF (RIGHT$(compositeElement$, 1) = "]") THEN				' array
					IF (RIGHT$(compositeElement$, 3) != "[i]") THEN		' show full array
						bracket = RINSTR (compositeElement$, "[")
						compositeElement$ = LEFT$(compositeElement$, bracket - 1) + "[i]"
						EXIT SELECT
					END IF
				END IF
				dot = RINSTR (compositeElement$, ".")
				IF (dot <= 1) THEN
					compositeElement$ = ""
				ELSE
					compositeElement$ = LEFT$(compositeElement$, dot - 1)
				END IF
			END IF
		CASE 3																' Detail Fixed string
			XuiSendMessage (compositeBox, #GetTextCursor, 0, @cursorLine, 0, 0, 4, 0)
			detailIndex = cursorLine
	END SELECT
'
'	Get type arrays (pass them back before exiting!!!)
'
	XxxPassTypeArrays ($$XGET, @pSize[], @pSize$[], @pAlias[], @pAlign[], @pSymbol$[], @pToken[], @pEleCount[], @pEleSymbol$[], @pEleToken[], @pEleAddr[], @pEleSize[], @pEleType[], @pEleStringSize[], @pEleUBound[])
'
'	step down compositeElement$ (".A.B.C")
'
	viewType = compositeType						' start at the top
	viewDataAddr = dataAddr
	viewElement$ = ""
	element$ = compositeElement$
'
	DO WHILE (LEN(element$) OR (action = 1))
		IFZ element$ THEN
			IF (action = 1) THEN
				IF (RIGHT$(viewElement$, 3) = "[i]") THEN
					IF (viewType < 0x20) THEN EXIT DO				' Can't step into simple types
					lenViewElement = LEN(viewElement$)
					viewElement$ = LEFT$(viewElement$, lenViewElement - 3)
					viewElement$ = viewElement$ + "[" + STRING$(stepDownIndex) + "]"
					IF (viewType = $$STRING) THEN
						arrayElementSize = fixedStringSize
					ELSE
						arrayElementSize = pSize[viewType]
					END IF
					viewDataAddr = viewDataAddr + stepDownIndex * arrayElementSize
				ELSE
					IF (stepDownIndex > pEleCount[viewType]) THEN EXIT DO
					stepDownType = pEleType[viewType, stepDownIndex]
					token = pEleToken[viewType, stepDownIndex]
					IF (token{$$KIND} = $$KIND_ARRAY_SYMBOLS) THEN
						viewElement$ = viewElement$ + pEleSymbol$[viewType, stepDownIndex] + "[i]"
						arrayUBound = pEleUBound[viewType, stepDownIndex]
					ELSE
						IF (stepDownType < 0x20) THEN EXIT DO		' Can't step into simple types
						viewElement$ = viewElement$ + pEleSymbol$[viewType, stepDownIndex]
					END IF
					viewDataAddr = viewDataAddr + pEleAddr[viewType, stepDownIndex]
					viewType = stepDownType
				END IF
			END IF
			EXIT DO
		END IF
'
' Get next requested subelement
'
		IF (element${0} != '.') THEN EXIT DO		' abort on syntax error
		dot2 = INSTR (element$, ".", 2)
		IF dot2 THEN
			nextElement$ = TRIM$(LEFT$(element$, dot2 - 1))
			element$ = MID$(element$, dot2)
		ELSE
			nextElement$ = TRIM$(element$)
			element$ = ""
		END IF
'
' Strip out []
'
		bracket = INSTR(nextElement$, "[")
		IF bracket THEN
			testElement$ = LEFT$(nextElement$, bracket - 1)
		ELSE
			testElement$ = nextElement$
		END IF
'
'		Identify type
'
		lastIndex = pEleCount[viewType] - 1
		FOR index = 0 TO lastIndex
			IF (testElement$ = pEleSymbol$[viewType, index]) THEN EXIT FOR
		NEXT index
		IF (index > lastIndex) THEN EXIT DO			' abort if not found
		nextType = pEleType[viewType, index]
		IF (nextType = $$STRING) THEN
			fixedStringSize = pEleStringSize[viewType, index]
		END IF
'
' if array, add in index offset to requested element (1D only)
'
		token = pEleToken[viewType, index]
		IF (bracket OR (token{$$KIND} = $$KIND_ARRAY_SYMBOLS)) THEN
			IF (token{$$KIND} != $$KIND_ARRAY_SYMBOLS) THEN EXIT DO		' not an array

			arrayUBound = pEleSize[viewType, index]

			IF (nextType < 0x20) THEN							' can't step into simple types
				viewElement$	= viewElement$ + testElement$ + "[i]"
				viewDataAddr	= viewDataAddr + pEleAddr[viewType, index]
				viewType			= nextType
				EXIT DO
			END IF

			IFZ bracket THEN nextElement$ = nextElement$ + "[i]"
			lenNextElement = LEN(nextElement$)
			IF (nextElement${lenNextElement - 1} != ']') THEN
				IF (bracket != lenNextElement) THEN EXIT DO							' syntax error
'
' add matching ']', then stop here
'
				viewElement$	= viewElement$ + nextElement$ + "i]"
				viewDataAddr	= viewDataAddr + pEleAddr[viewType, index]
				viewType			= nextType
				IF (action = 1) THEN								' step into array
					element$ = ""
					DO DO
				END IF
				EXIT DO
			END IF
'
' stop here if no index ([])
'
			arrayIndex$ = MID$(nextElement$, bracket + 1, (lenNextElement - bracket -1))
			arrayIndex$ = TRIM$(arrayIndex$)
			IFZ arrayIndex$ THEN
				viewElement$	= viewElement$ + testElement$ + "[i]"
				viewDataAddr	= viewDataAddr + pEleAddr[viewType, index]
				viewType			= nextType
				IF (action = 1) THEN								' step into array
					element$ = ""
					DO DO
				END IF
				EXIT DO
			END IF
'
' test for syntax error
'
			lenArrayIndex = LEN(arrayIndex$)
			FOR i = 0 TO lenArrayIndex - 1
				cchar = arrayIndex${i}
				IF ((cchar < '0') OR (cchar > '9')) THEN							' syntax error
					viewElement$	= viewElement$ + testElement$ + "[i]"
					viewDataAddr	= viewDataAddr + pEleAddr[viewType, index]
					viewType			= nextType
					IF (action = 1) THEN								' step into array
						element$ = ""
						DO DO
					END IF
					EXIT DO
				END IF
			NEXT i
'
' get array index
'
			arrayIndex# = DOUBLE (arrayIndex$)
			IF (arrayIndex# > 0x7FFFFFFF) THEN											' index too large
				viewElement$	= viewElement$ + testElement$ + "[i]"
				viewDataAddr	= viewDataAddr + pEleAddr[viewType, index]
				viewType			= nextType
				EXIT DO
			END IF
			arrayIndex = arrayIndex#
			IF (arrayIndex > arrayUBound) THEN EXIT DO							' index too large
			arrayElementSize = pSize[nextType]
			arrayOffset = arrayIndex * arrayElementSize
'
' add in offset to array element
'
			viewElement$ = viewElement$ + testElement$ + "[" + STRING$(arrayIndex) + "]"
			viewDataAddr = viewDataAddr + pEleAddr[viewType, index] + arrayOffset
			viewType = nextType
			DO LOOP
		END IF
'
		IF (nextType < 0x20) THEN EXIT DO						' can't step into simple types
'
		viewElement$ = viewElement$ + nextElement$
		viewDataAddr = viewDataAddr + pEleAddr[viewType, index]
		viewType = nextType
	LOOP
'
' detail fixed string?
'
	IF (action = 3) THEN
		IF (pEleType[viewType, detailIndex] = $$STRING) THEN
			stringSource = $$SourceComposites
			stringFixed = pEleStringSize[viewType, detailIndex]
			IF (RIGHT$(viewElement$, 3) = "[i]") THEN
				stringSymbol$ = compositeSymbol$ + RCLIP$(viewElement$, 2) + STRING$(detailIndex) + "]"
			ELSE
				stringSymbol$ = compositeSymbol$ + viewElement$ + pEleSymbol$[viewType, detailIndex]
			END IF
			stringDataAddr = viewDataAddr + pEleAddr[viewType, detailIndex]
			stringHandle$ = HEXX$(stringDataAddr, 8)		' actually, data address
			XxxPassTypeArrays ($$XSET, @pSize[], @pSize$[], @pAlias[], @pAlign[], @pSymbol$[], @pToken[], @pEleCount[], @pEleSymbol$[], @pEleToken[], @pEleAddr[], @pEleSize[], @pEleType[], @pEleStringSize[], @pEleUBound[])
			VariablesString (stringBox, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		ELSE
			XxxPassTypeArrays ($$XSET, @pSize[], @pSize$[], @pAlias[], @pAlign[], @pSymbol$[], @pToken[], @pEleCount[], @pEleSymbol$[], @pEleToken[], @pEleAddr[], @pEleSize[], @pEleType[], @pEleStringSize[], @pEleUBound[])
		END IF
		RETURN
	END IF
'
' display the element
'
	compositeElement$ = viewElement$
	XuiSendMessage (compositeBox, #SetTextString, 0, 0, 0, 0, 8, @compositeElement$)
	XuiSendMessage (compositeBox, #RedrawText, 0, 0, 0, 0, 8, 0)
'
	IF (RIGHT$(viewElement$, 3) = "[i]") THEN
		displayArray = $$TRUE
		currentType = viewType
		IF (currentType = $$STRING) THEN
			arrayElementSize = fixedStringSize
		ELSE
			arrayElementSize = pSize[currentType]
		END IF
		lastIndex = arrayUBound
		type$ = varTypes$[currentType]
		IF (currentType > 0x21) THEN
			lenType = LEN(type$)
			SELECT CASE TRUE
				CASE (lenType > 8)
					type$ = LEFT$(type$, 7) + "*"
				CASE (lenType < 8)
					type$ = LJUST$(type$, 8)
			END SELECT
		END IF
		location = viewDataAddr
	ELSE
		lastIndex = pEleCount[viewType] - 1
	END IF
'
	DIM textArray$[lastIndex]
	FOR index = 0 TO lastIndex
		IF displayArray THEN
			token = 0														' type set above (same for all elements)
			symbol$ = LJUST$(STRING$(index), 20)
		ELSE
			token = pEleToken[viewType, index]
			currentType	= pEleType[viewType, index]
			type$ = varTypes$[currentType]
			IF (currentType > 0x21) THEN
				lenType = LEN(type$)
				SELECT CASE TRUE
					CASE (lenType > 8)
						type$ = LEFT$(type$, 7) + "*"
					CASE (lenType < 8)
						type$ = LJUST$(type$, 8)
				END SELECT
			END IF
'
			symbol$ = pEleSymbol$[viewType, index]
			IF (token{$$KIND} = $$KIND_ARRAY_SYMBOLS) THEN
				symbol$ = symbol$ + "[]"
			END IF
			lenSymbol = LEN(symbol$)
			SELECT CASE TRUE
				CASE (lenSymbol < 20)							' pad symbol to 20 chars
					symbol$ = LJUST$(symbol$, 20)

				CASE (lenSymbol > 20)							' truncate symbol to 20 chars
					IF (token{$$KIND} = $$KIND_ARRAY_SYMBOLS) THEN		' Retain []
						symbol$ = LEFT$(symbol$, 17) + "*[]"
					ELSE
						symbol$ = LEFT$(symbol$, 19) + "*"
					END IF
			END SELECT
			location = viewDataAddr + pEleAddr[viewType, index]
		END IF
'
		location$	= HEX$(location, 8)
		IF (token{$$KIND} = $$KIND_ARRAY_SYMBOLS) THEN
			value$ = " <array>"
			hexValue$ = "                 "
		ELSE
			SELECT CASE TRUE
				CASE (currentType >= 0x20)						' composites
					value$ = " <composite>"
					hexValue$ = "                 "
				CASE (currentType = $$STRING)					' Fixed STRING
					IF displayArray THEN
						eleSize = fixedStringSize
					ELSE
						eleSize = pEleStringSize[viewType, index]
					END IF
					fixedType$ = "STRING*" + STRING$(eleSize)
					hexValue$ = " " + LJUST$(fixedType$, 16)
'
' value is first few characters of string
'
					IF (eleSize > 61) THEN
						firstFew = 60
					ELSE
						firstFew = eleSize
					END IF
					value$ = NULL$ (firstFew)
					FOR i = 0 TO firstFew - 1
						value${i} = UBYTEAT (location, i)
					NEXT i
					value$ = " \"" + XstBinStringToBackString$ (@value$)
'
					IF (LEN(value$) > 63) THEN
						value$ = LEFT$(value$, 62) + "\"*"
					ELSE
						value$ = value$ + "\""
					END IF
				CASE (currentType = $$GIANT)
					word1 = XLONGAT (location)
					word2 = XLONGAT (location, 4)
					value$$ = GMAKE(word2, word1)
					value$ = STR$(value$$)
					hexValue$ = " " + HEX$(word2, 8) + HEX$(word1, 8)
				CASE (currentType = $$SINGLE)
					word1 = XLONGAT (location)
					value! = SMAKE(word1)
					value$ = STR$(value!)
					hexValue$ = " " + HEX$(word1, 8) + "        "
				CASE (currentType = $$DOUBLE)
					word1 = XLONGAT (location)
					word2 = XLONGAT (location, 4)
					value# = DMAKE(word2, word1)
					value$ = STR$(value#)
					hexValue$ = " " + HEX$(word2, 8) + HEX$(word1, 8)
				CASE (currentType = $$GOADDR), (currentType = $$SUBADDR), (currentType = $$FUNCADDR)
					word1 = XLONGAT (location)
					labels = XxxGetLabelGivenAddress (word1, @labels$[])
					IF (currentType = $$FUNCADDR) THEN
						XxxPassFunctionArrays ($$XGET, @funcSymbol$[], @funcToken[], @funcScope[])
					END IF
					FOR j = 0 TO (labels - 1)
						label$ = labels$[j]
						SELECT CASE currentType
							CASE $$GOADDR						' %g%<user's GOTO label>%<func#>
								IF (LEFT$(label$, 3) = "%g%") THEN
									value$ = " " + MID$(label$, 4)
									ipercent = RINSTR (value$, "%")
									IF ipercent THEN value$ = LEFT$(value$, ipercent - 1)
									EXIT FOR
								END IF
							CASE $$SUBADDR					' %s%<user's SUB label>%<func#>
								IF (LEFT$(label$, 3) = "%s%") THEN
									value$ = " " + MID$(label$, 4)
									ipercent = RINSTR(value$, "%")
									IF ipercent THEN value$ = LEFT$(value$, ipercent - 1)
									EXIT FOR
								END IF
							CASE ELSE
								label$ = MID$(label$, 2)				' Strip leading _
								iat = RINSTR (label$, "@")			' Strip trailing @###
								IF iat THEN label$ = LEFT$(label$, iat - 1)
								FOR funcNumber = 0 TO maxFuncNumber
									IF funcSymbol$[funcNumber] THEN
										IF (label$ = funcSymbol$[funcNumber]) THEN
											value$ = " " + label$
											EXIT FOR 2
										END IF
									END IF
								NEXT funcNumber
						END SELECT
					NEXT j
					IF (LEN(value$) > 64) THEN
						value$ = LEFT$(value$, 63) + "*"
					END IF
					IF (currentType = $$FUNCADDR) THEN
						XxxPassFunctionArrays ($$XSET, @funcSymbol$[], @funcToken[], @funcScope[])
					END IF
				CASE (currentType = $$UBYTE)
					byte1 = UBYTEAT (location)
					value$ = STR$(byte1)
					hexValue$ = " " + HEX$(byte1, 2)	+ "              "
				CASE (currentType = $$SBYTE)
					byte1 = SBYTEAT (location)
					value$ = STR$(byte1)
					hexValue$ = " " + HEX$(byte1, 2)	+ "              "
				CASE (currentType = $$USHORT)
					short1 = USHORTAT (location)
					value$ = STR$(short1)
					hexValue$ = " " + HEX$(short1, 4)	+ "            "
				CASE (currentType = $$SSHORT)
					short1 = SSHORTAT (location)
					value$ = STR$(short1)
					hexValue$ = " " + HEX$(short1, 4)	+ "            "
				CASE (currentType = $$ULONG)
					word1 = ULONGAT (location)
					value$ = STR$(ULONG(word1))
					hexValue$ = " " + HEX$(word1, 8)	+ "        "
				CASE ELSE
					word1 = XLONGAT (location)
					value$ = STR$(word1)
					hexValue$ = " " + HEX$(word1, 8)	+ "        "
			END SELECT
		END IF  ' kind = array
'
		textArray$[index] = type$ + "  " + symbol$ + "  " + location$ + "  " + hexValue$ + " " + value$
'
		IF displayArray THEN
			location = location + arrayElementSize
		END IF
	NEXT index
'
	XxxPassTypeArrays ($$XSET, @pSize[], @pSize$[], @pAlias[], @pAlign[], @pSymbol$[], @pToken[], @pEleCount[], @pEleSymbol$[], @pEleToken[], @pEleAddr[], @pEleSize[], @pEleType[], @pEleStringSize[], @pEleUBound[])
'
	XuiSendMessage (compositeBox, #SetTextArray, 0, 0, 0, 0, 4, @textArray$[])
	XuiSendMessage (compositeBox, #SetTextCursor, 0, 0, 0, 0, 4, 0)
	XuiSendMessage (compositeBox, #RedrawText, 0, 0, 0, 0, 4, 0)
END FUNCTION
'
'
' #############################
' #####  VariableSort ()  #####
' #############################
'
FUNCTION  VariableSort (tok[], symbol$[], reg[], addr[], Low, High)
	IF (Low >= High) THEN RETURN			' array contains fewer than two elements
	IF ((High - Low) = 1) THEN				' only two elements left
		IF (symbol$[Low] > symbol$[High]) THEN
			SWAP tok[Low],			tok[High]
			SWAP symbol$[Low],	symbol$[High]
			SWAP reg[Low],			reg[High]
			SWAP addr[Low],			addr[High]
		END IF
		RETURN
	END IF
'
	Middle = (High + Low) >> 1
	SWAP tok[High],			tok[Middle]
	SWAP symbol$[High],	symbol$[Middle]
	SWAP reg[High],			reg[Middle]
	SWAP addr[High],		addr[Middle]
'
	partition$ = symbol$[High]
	DO
		i = Low: j = High
		DO WHILE ((i < j) AND (symbol$[i] <= partition$))
			INC i
		LOOP
		DO WHILE ((j > i) AND (symbol$[j] >= partition$))
			DEC j
		LOOP
		IF (i < j) THEN
			SWAP tok[i],			tok[j]
			SWAP symbol$[i],	symbol$[j]
			SWAP reg[i],			reg[j]
			SWAP addr[i],			addr[j]
		END IF
	LOOP WHILE (i < j)
'
	IF (i != High) THEN
		SWAP tok[i],			tok[High]
		SWAP symbol$[i],	symbol$[High]
		SWAP reg[i],			reg[High]
		SWAP addr[i],			addr[High]
	END IF
'
	IF ((i-Low) < (High-i)) THEN
		IF i THEN VariableSort (@tok[], @symbol$[], @reg[], @addr[], Low, i-1)
		VariableSort (@tok[], @symbol$[], @reg[], @addr[], i+1, High)
	ELSE
		VariableSort (@tok[], @symbol$[], @reg[], @addr[], i+1, High)
		IF i THEN VariableSort (@tok[], @symbol$[], @reg[], @addr[], Low, i-1)
	END IF
END FUNCTION
'
'
' ##########################
' #####  HotFrames ()  #####
' ##########################
'
FUNCTION  HotFrames (grid, message, v0, v1, v2, v3, r0, (r1, r1$, r1$[]))
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  FRAMEINFO  frameInfo[]
	SHARED  editFunction,  fileType,  frameDetail,  variableUp
'
	$label				= 1
	$list					= 2
	$button0			= 3
	$button1			= 4
	$button2			= 5
'
	SELECT CASE message
		CASE #Callback			: GOSUB Callback
		CASE #DisplayWindow	: GOSUB DisplayWindow
	END SELECT
	RETURN
'
'
' *****  Callback  *****
'
SUB Callback
	message = r1
	SELECT CASE message
		CASE #CloseWindow		: XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		CASE #Selection			: GOSUB Selection
	END SELECT
END SUB
'
'
' *****  DisplayWindow  *****  r1$ = default function name
'
SUB DisplayWindow
	IF (fileType != $$Program) THEN
		Message (" HotFrames() \n\n no program loaded ")
		RETURN
	END IF
	UpdateFrames ()
	XuiSendToKid (grid, #DisplayWindow, 0, 0, 0, 0, 1, 0)
END SUB
'
'
' *****  Selection  *****  r0 = 2345 = List/Button012
'
SUB Selection
	SELECT CASE r0
		CASE $list
			IF (v0 < 0) THEN
				XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
				EXIT SUB
			END IF
			NEXT CASE
		CASE $list, $button0
			IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
				ResetDataDisplays (0)
				RETURN
			END IF
			XuiSendMessage (grid, #GetTextCursor, 0, @viewLine, 0, 0, $list, 0)
			XuiSendMessage (grid, #GetTextArrayLine, viewLine, 0, 0, 0, $list, @view$)
			funcPtr = XLONG(view$)
			funcNumber = frameInfo[funcPtr].funcNumber
			IF (funcNumber < 0) THEN EXIT SUB
			line = frameInfo[funcPtr].funcLine
'			line = XLONG (MID$(view$, 6))						' transit --> line 0
			Display (funcNumber, line, 0, -1, -1)		' Display checks validity of funcNumber
			IF variableUp THEN UpdateVariables()
		CASE $button1
			frameDetail = NOT frameDetail
			UpdateFrames ()
		CASE $button2
			XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
	END SELECT
END SUB
END FUNCTION
'
'
' #############################
' #####  UpdateFrames ()  #####
' #############################
'
'	Update the Frame box
'
'	In:				none
'	Out:			none
'	Return:		none
'
'	Discussion:
'		88k requires the use of a WALK array to save function base frame address
'		NT:	previous ebp = [ebp]
'				return addr  = [ebp + 4]
'
'		Update assumes that frame functions do not include XIT functions invoked
'			after a signal.  So DON'T generate walker code when compiling Blowback,
'			XitMain, etc.
'
'		Compare frame return address (0x6C) with previous frame's "call" addr (0x64)
'			- If not equal, insert * Alien between them
'
'		##ALARMWALKER
'			- 0 if alarm is not engaged
'			- else, it is the WALKOFFSET at the alarm time
'					- If alarm is engaged, insert alarm entries after ALARMWALKER
'
'		SXIP:
'			1)  SXIP not in user function
'					- identify function called by last frame function
'							- frame x64 - 8 = bsr/jsr to called routine
'							- decode jump address, get name from XxxGetLabelGivenAddress ()
'									- If not found, use <Alien>
'					- no idea where SXIP is (not necessarily in called function)
'							- optional:  display  "addr  SXIP"
'
'			2)  SXIP in body of last frame function (line 1 to n)
'					- SXIP function IS last frame function
'					- replace its line number with SXIP line number
'
'			3)  SXIP in EPILOG of last frame function (n < addr < PROLOG)
'					- last frame function is SXIP function  (addr < PROLOG - 8)
'							- replace its line number with "exit"
'					- SXIP function frame has been removed  (addr >= PROLOG - 8)
'							- add in an "exit" frame with this function
'
'			4)  SXIP in PROLOG of last frame function (n >= PROLOG)
'					- SXIP function may not be on frame yet
'					- If it is, then line number is "entry"
'					- TEST:
'							- last frame function != SXIP function
'									- SXIP function not on frame yet
'									- ADD frame entry:  "entry  (SXIP-function)"
'							- last frame function = SXIP function
'									- If line number is "entry":  this is SXIP function (done)
'									- Else, this is NOT SXIP function (a recursive call)
'											- (recursive call can't be initiated from PROLOG/EPILOG)
'											- ADD frame entry:  "entry  (SXIP-function)"
'
'		NOTES:
'			- ALL branches/jumps OUT of function store r1 in walk array
'
'		Can't see giving user access to variables in other that last user frame
'			and then only if SXIP on a line boundary (breakpoint or break key) or
'			in inline code where variables are in a determined state
'			- Can't give source line debugger that works on non-boundary
'			- problems with prior frames:
'					1) calls other user X functions
'							r14-r25 are saved only when needed.  Would have to bop down line
'							of called functions checking for the first saving of that variable
'							on a frame and record its location.
'					2) above is destroyed if a non-X function is in the sequence (and
'							executes a call to a user X function) because the location of
'							r14-r25 is unknown
'					3) a signal yanks out of a function, then calls another user
'							function which breaks.  Variables in the original function are
'							in an indeterminate state (e.g. signal executed during an
'							intrinsic creating a stack and using r14..., alarm dispatcher)
'
' To do elsewhere:
'		Breakpoints:
'			- move ":" on comment or blank to next non-comment/blank line
'
FUNCTION  UpdateFrames ()
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  lineAddr[],  lineLast[]
	SHARED  FRAMEINFO  frameInfo[]
	SHARED  framesBox,  frameDetail,  variableUp
	SHARED  exeFunction,  exeLine
	SHARED  userGoFrame
	SHARED  EXCEPTION_RECORD  exceptionRecord
	SHARED  EXCEPTION_CONTEXT  exceptionContext
	STATIC  item$[]
	STATIC  FRAMEINFO  tempInfo[]
'
	IFZ (##USERRUNNING AND ##SIGNALACTIVE) THEN
		ResetDataDisplays(0)
		RETURN
	END IF
'
	IFZ item$[] THEN DIM item$[31]
	uitem		= UBOUND(item$[])
	uframe	= UBOUND(frameInfo[])
'
	exeFunction	= 0
	exeLine			= 0
	frame				= exceptionContext.ebp
	funcAddress	= exceptionRecord.exceptionAddress
	itemPtr			= -1
	item$[0]		= ""
	DO WHILE (frame < userGoFrame)
		INC itemPtr
		IF ((itemPtr > uitem) OR (itemPtr > uframe)) THEN
			uitem = (itemPtr + (itemPtr >> 1)) OR 7
			REDIM item$[uitem]
			uframe = uitem
			REDIM frameInfo[uframe]
		END IF
		frameFuncNumber = GetFuncNumberGivenAddress (funcAddress)
		frame$ = ""																' Number inserted on reorder below
		IF (frameFuncNumber >= 0) THEN
			line = 0
			frameFuncLine = 0
			lastLine = lineLast[frameFuncNumber]
			lineAddr = lineAddr[frameFuncNumber, 0]
			DO UNTIL (line > lastLine)
				nextAddr = lineAddr[frameFuncNumber, line + 1]
				IF ((lineAddr <= funcAddress) AND (funcAddress < nextAddr)) THEN
					frameFuncLine = line
					EXIT DO
				END IF
				lineAddr = nextAddr
				INC line
			LOOP
			IF (frameFuncLine = lastLine) THEN			' start of last line is OK
				IF (funcAddress != lineAddr) THEN
					frameFuncLine = 0										' User can't see transit lines
					XxxFunctionName ($$XGET, @funcName$, frameFuncNumber)
					label$ = "_" + funcName$
					prologAddr = XxxGetAddressGivenLabel(label$)
					IF (funcAddress < prologAddr) THEN
						frame$ = frame$ + "    exit  "		' function EPILOG
						IFZ (exeFunction OR exeLine) THEN
							exeFunction = frameFuncNumber
							exeLine = lastLine
						END IF
					ELSE
						frame$ = frame$ + "   entry  "		' function PROLOG
						IFZ (exeFunction OR exeLine) THEN
							exeFunction = frameFuncNumber
							exeLine = 0
						END IF
					END IF
				END IF
			END IF
			IF frameFuncLine THEN
				frame$ = frame$ + RJUST$(STRING$(frameFuncLine), 8) + "  "
				IFZ (exeFunction OR exeLine) THEN
					exeFunction = frameFuncNumber
					exeLine = frameFuncLine
				END IF
			END IF
			XxxFunctionName ($$XGET, @funcName$, frameFuncNumber)
			IF (LEN(funcName$) > 32) THEN
				funcName$ = LEFT$(funcName$, 31) + "*"
			END IF
			item$[itemPtr] = frame$ + funcName$
			frameInfo[itemPtr].frameAddr	= frame
			frameInfo[itemPtr].funcAddr		= funcAddress
			frameInfo[itemPtr].funcNumber	= frameFuncNumber
			frameInfo[itemPtr].funcLine		= frameFuncLine
		ELSE
'			It's not a user's function
			tag$ = "  < * Alien * >"
'
'			RuntimeError "removed" by XitMain()
'
'			labels = XxxGetLabelGivenAddress (funcAddress, @labels$[])
'			IF labels THEN
'				FOR i = 0 TO labels
'				SELECT CASE labels$[i]  ' busted
'					SWAP labels$[i], label$
'					SELECT CASE label$
'						CASE "_XxxRuntimeError"		: tag$ = "  < * Runtime Error * >": EXIT FOR
'						CASE "_XxxRuntimeError2"	: tag$ = "  < * Runtime Error * >": EXIT FOR
'					END SELECT
'				NEXT i
'			END IF
'
			item$[itemPtr] = frame$ + HEX$(funcAddress, 8) + tag$
			frameInfo[itemPtr].frameAddr	= frame
			frameInfo[itemPtr].funcAddr		= funcAddress
			frameInfo[itemPtr].funcNumber	= -1
			frameInfo[itemPtr].funcLine		= -1
		END IF
'		PRINT "UpdateFrames() : A : funcAddr & frameAddr = "; HEX$(funcAddress,8);; HEX$(frame,8)
		funcAddress	= XLONGAT(frame,4)				' return address in calling function
		frame				= XLONGAT(frame)					' calling frame address = [frame]
'		PRINT "UpdateFrames() : B : funcAddr & frameAddr = "; HEX$(funcAddress,8);; HEX$(frame,8)
	LOOP
'	PRINT

	lastItem = 0
	IFZ item$[0] THEN
		DIM item$[]
		view$ = ""
	ELSE
		showItem = 0
		DIM tempItem$[itemPtr]
		DIM tempInfo[itemPtr]
		itemCount = 0															' detail and reverse order
		FOR i = itemPtr TO 0 STEP -1
			j = itemPtr - i
			tempInfo[j] = frameInfo[i]
			IF (frameInfo[i].funcNumber < 0) THEN
				IFZ frameDetail THEN DO NEXT
			ELSE
				showItem = itemCount
			END IF
			tempItem$[itemCount] = RJUST$(STRING$(j), 3) + "  " + item$[i]
			INC itemCount
		NEXT i
		IFZ itemCount THEN
			DIM item$[]
			view$ = ""
		ELSE
			SWAP tempItem$[], item$[]
			lastItem = itemCount - 1
			REDIM item$[lastItem]
			view$ = item$[showItem]
		END IF
		SWAP tempInfo[], frameInfo[]
	END IF
'
	XuiSendMessage (framesBox, #SetTextArray, 0, 0, 0, 0, 2, @item$[])
	XuiSendMessage (framesBox, #SetTextCursor, 0, showItem, 0, 0, 2, 0)
	XuiSendMessage (framesBox, #RedrawText, 0, 0, 0, 0, 2, 0)
	funcPtr = XLONG (view$)
	funcNumber = frameInfo[funcPtr].funcNumber
	line = XLONG (MID$(view$, 6))						' transit --> line 0
	Display (funcNumber, line, 0, -1, -1)		' Display checks validity of funcNumber
	IF variableUp THEN UpdateVariables()
END FUNCTION
'
'
' ############################
' #####  Pop16Frames ()  #####
' ############################
'
'	Called by XitMain after STACK_OVERFLOW
'
FUNCTION  Pop16Frames (signalCode, signalInfo)
	SHARED  EXCEPTION_RECORD  exceptionRecord
	SHARED  EXCEPTION_CONTEXT  exceptionContext
	SHARED  userGoFrame

	frame				= exceptionContext.ebp
	funcAddress	= exceptionRecord.exceptionAddress
	FOR i = 0 TO 16
		IF (frame >= userGoFrame) THEN EXIT FOR
'		PRINT i, HEX$(frame,8), HEX$(funcAddress,8)
		funcAddress	= XLONGAT(frame,4)				' return address in calling function
		frame				= XLONGAT(frame)					' calling frame address = [frame]
	NEXT i
	exceptionContext.eip = funcAddress
	XxxSetFrameAddr (frame)
	XitMain (signalCode, signalInfo)
END FUNCTION
'
'
' ##############################
' #####  XitGetDECLARE ()  #####
' ##############################
'
' Get DECLARE line for funcName$
'
'	In:				funcName$
'	Out:			declare$
' Return:		error				0 no error
'												$$XitEnvironmentInactive
'												$$XitTextMode
'												$$XitProgramRunning
'												$$XitIllegalFunctionName
'
FUNCTION  XitGetDECLARE (funcName$, declare$)
	SHARED  prog[],  funcAltered[],  funcCursorPosition[]
	SHARED  environmentActive,  fileType,  editFunction
	SHARED  programAltered,  textAlteredSinceLastSave
'
	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF (fileType != $$Program) THEN RETURN ($$XitTextMode)
	IF ##USERRUNNING THEN RETURN ($$XitProgramRunning)
	error = FunctionNameToNumber(@funcName$, @funcNumber)
	IF (error = $$XitIllegalFunctionName) THEN RETURN (error)
	IFZ funcNumber THEN RETURN (0)
'
	IFZ editFunction THEN
		redisplay = $$FALSE								' prepare for PROLOG alterations
		reportBogusRename = $$FALSE
		RestoreTextToProg (redisplay, reportBogusRename)
	END IF
'
	declare$ = ""
	IFZ prog[0,] THEN RETURN (0)

	uLine = UBOUND(prog[0,])						' Initialize for FindDECLARE
	line = uLine
	foundDeclare	= $$FALSE							' not used
	firstDeclare	= -1
	lastDeclare		= -1
	GOSUB FindDECLARE
	IF (line >= 0) THEN
		ATTACH prog[0,line,] TO tok[]
'		IF tok[] THEN
			XxxDeparser(@tok[], @declare$)
			ATTACH tok[] TO prog[0,line,]
'		END IF
	END IF
	RETURN (0)
'
'	Same  subroutine in XitSetDECLARE
'
'	*****  FindDECLARE  *****
'		In:				funcNumber
'							uLine						= UBOUND(prog[0,])
'							line						= start line number (for continuations)
'							foundDeclare		= initialized
'							firstDeclare
'							lastDeclare
'
'		Out:			line					= #   line number of declare for funcNumber
'															-1  not present
'							tokPtr				= token index to func token
'					If not present:
'							foundDeclare	= at least 1 DECLARE exists
'							firstDeclare	= line number of first DECLARE
'							lastDeclare		= line number of last DECLARE
'
'		Discussion:
'			DECLARE and INTERNAL only.  This allows user application to
'			 "overwrite" library function.
'
SUB FindDECLARE
	ATTACH prog[0,] TO func[]
	DO UNTIL (line < 0)
		toks = func[line, 0]{$$BYTE0}
		IF (toks < 2) THEN DEC line: DO DO			' newLine

		ATTACH func[line,] TO tok[]
'		IFZ tok[] THEN DEC line : DO LOOP
		isDeclare = CheckDECLARE (@tok[], @declareFuncNumber)
		ATTACH tok[] TO func[line,]
		IF isDeclare THEN
			IF (funcNumber = declareFuncNumber) THEN
				ATTACH func[] TO prog[0,]
				EXIT SUB
			END IF
			foundDeclare = $$TRUE
			firstDeclare = line
			IF (lastDeclare < 0) THEN lastDeclare = line
		END IF
		DEC line
	LOOP
	ATTACH func[] TO prog[0,]
END SUB
END FUNCTION
'
'
' ########################################
' #####  XitGetDisplayedFunction ()  #####
' ########################################
'
'	Get currently displayed function
'
'	In:				funcName$
'	Out:			none
'	Return:		error				0 = no error
'												$$XitEnvironmentInactive
'												$$XitTextMode
'
FUNCTION  XitGetDisplayedFunction (funcName$)
	SHARED  editFunction,  fileType
	SHARED  environmentActive

	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF (fileType != $$Program) THEN RETURN ($$XitTextMode)

	XxxFunctionName ($$XGET, @funcName$, editFunction)
	RETURN (0)
END FUNCTION
'
'
' ###############################
' #####  XitGetFunction ()  #####
' ###############################
'
'	Get function
'
'	In:				funcName$
'	Out:			text$[]
'	Return:		error				0 = no error
'												$$XitEnvironmentInactive
'												$$XitTextMode
'												$$XitIllegalFunctionName
'												$$XitFunctionUndefined
'
FUNCTION  XitGetFunction (funcName$, text$[])
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[]
	SHARED  editFunction,  fileType,  environmentActive
'
	DIM text$[]
	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF (fileType != $$Program) THEN RETURN ($$XitTextMode)
	error = FunctionNameToNumber(@funcName$, @funcNumber)
	IF error THEN RETURN (error)
'
	IF ((funcNumber = editFunction) AND (NOT ##USERRUNNING)) THEN
		redisplay = $$TRUE
		reportBogusRename = $$TRUE
		RestoreTextToProg (redisplay, reportBogusRename)
	END IF
'
	ATTACH prog[funcNumber,] TO func[]
	lastLine = UBOUND(func[])
	DIM text$[lastLine]
	FOR line = 0 TO lastLine
		ATTACH func[line,] TO tok[]
'		IFZ tok[] THEN DO NEXT
		startToken = tok[0]
		tok[0] = startToken AND 0x3FFF00FF		' strip BP/EXE/errno from token line
		XxxDeparser(@tok[], @lineText$)
		tok[0] = startToken										' restore startToken
		ATTACH lineText$ TO text$[line]
		ATTACH tok[] TO func[line,]
	NEXT line
	ATTACH func[] TO prog[funcNumber,]
	RETURN (0)
END FUNCTION
'
'
' ################################
' #####  XitLoadFunction ()  #####
' ################################
'
'	Load function from file
'
'	In:				funcName$
'						fileName$
'	Out:			none
'	Return:		error				0 = no error
'												$$XitEnvironmentInactive
'												$$XitTextMode
'												$$XitIllegalFunctionName
'												##ERROR...  (for file operations)
'
FUNCTION  XitLoadFunction (funcName$, fileName$)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[]
	SHARED  editFunction,  fileType,  environmentActive
'
	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF (fileType != $$Program) THEN RETURN ($$XitTextMode)
	error = FunctionNameToNumber(@funcName$, @funcNumber)
	IF (error = $$XitIllegalFunctionName) THEN RETURN (error)

	error = XstLoadStringArray (@fileName$, @text$[])
	IF error THEN RETURN (##ERROR)
	IFZ text$[] THEN RETURN (0)
	declare$ = text$[0]
	XxxParseSourceLine (@declare$, @tok[])
	isDeclare = CheckDECLARE (@tok[], @declareFuncNumber)
	IFZ isDeclare THEN
		declare$ = "DECLARE FUNCTION  " + funcName$ + " ()"
	ELSE
		IF (funcNumber != declareFuncNumber) THEN
			toks = tok[0]{$$BYTE0}
			FOR i = 1 TO toks
				token = tok[i]
				IF (token{$$KIND} = $$KIND_FUNCTIONS) THEN
					tok[i] = (token AND 0xFFFF0000) OR funcNumber
					EXIT FOR
				END IF
			NEXT i
			XxxDeparser(@tok[], @declare$)
		END IF
		uText = UBOUND(text$[])
		IF (uText = 0) THEN
			DIM text$[]
		ELSE
			FOR line = 0 TO uText - 1
				SWAP text$[line], text$[line + 1]
			NEXT line
			REDIM text$[uText - 1]
		END IF
	END IF
	XitSetDECLARE (@funcName$, @declare$)
	error = XitSetFunction (@funcName$, @text$[])
	RETURN (error)
END FUNCTION
'
'
' ###############################
' #####  XitMergePROLOG ()  #####
' ###############################
'
'	Merge file into PROLOG (usually a .dec file)
'
'	In:				fileName$
'	Out:			none
'	Return:		error				0 = no error
'												$$XitEnvironmentInactive
'												$$XitTextMode
'												##ERROR...  (for file operations)
'	Discussion:
'		Sections:	COMPOSITE Declarations
'								First line to last END TYPE
'							EXTERNAL FUNCTION Declarations
'								After last END TYPE to last EXTERNAL FUNCTION
'							CONSTANT Declarations
'								After last EXTERNAL FUNCTION to last line
'			TYPES and CONSTANTS are not required.
'
FUNCTION  XitMergePROLOG (fileName$)
	SHARED  prog[],  funcAltered[]
	SHARED  funcCursorPosition[],  funcNeedsTokenizing[]
	SHARED  xitGrid,  editFunction,  fileType,  environmentActive
	SHARED  programAltered,  textAlteredSinceLastSave
	SHARED  T_DECLARE,  T_INTERNAL,  T_EXTERNAL
	SHARED  T_FUNCTION, T_CFUNCTION,  T_SFUNCTION,  T_END,  T_TYPE
'
	$endType	= 1
	$function	= 2
	$constant	= 3
'
	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF (fileType != $$Program) THEN RETURN ($$XitTextMode)
'
	error = XstLoadStringArray (@fileName$, @text$[])
	IF error THEN RETURN (##ERROR)
	IFZ text$[] THEN RETURN (0)
'
	IFZ editFunction THEN
		redisplay = $$FALSE								' prepare for PROLOG alterations
		reportBogusRename = $$FALSE
		RestoreTextToProg (redisplay, reportBogusRename)
	END IF
	TextToTokenArray (@text$[], @func[], 0, $$FALSE)
	uFunc = UBOUND(func[])
'
'	*****  TYPE Declarations  *****
'
	insertProlog	= 0
	firstFuncLine	= 0
	lastFuncLine	= -1											' find func[] TYPEs
	FOR line = firstFuncLine TO uFunc
		ATTACH func[line,] TO tok[]
'		IFZ tok[] THEN DO NEXT
		GOSUB CheckTok
		ATTACH tok[] TO func[line,]
		SELECT CASE lineType
			CASE $endType:		lastFuncLine = line
			CASE $function:		EXIT FOR					' no TYPEs after FUNCTION
		END SELECT
	NEXT line
	IF (lastFuncLine >= 0) THEN							' Insertion point
		IF prog[0,] THEN
			ATTACH prog[0,] TO prolog[]
			uProlog = UBOUND(prolog[])
			insertLine = -1
			FOR line = insertProlog TO uProlog
				ATTACH prolog[line,] TO tok[]
'				IFZ tok[] THEN DO NEXT
				GOSUB CheckTok
				ATTACH tok[] TO prolog[line,]
				SELECT CASE lineType
					CASE $endType:		insertLine = line + 1
					CASE $function:		EXIT FOR
				END SELECT
			NEXT line
			IF (insertLine < 0) THEN insertLine = line
			insertProlog = insertLine
			ATTACH prolog[] TO prog[0,]
		END IF
		GOSUB MergeFunc
		IF (lastFuncLine >= uFunc) THEN GOTO Done
		firstFuncLine	= lastFuncLine + 1
	END IF
'
'	*****  FUNCTION Declarations  *****
'
	lastFuncLine = -1												' find func[] FUNCTIONs
	FOR line = firstFuncLine TO uFunc
		ATTACH func[line,] TO tok[]
'		IFZ tok[] THEN DO NEXT
		GOSUB CheckTok
		ATTACH tok[] TO func[line,]
		SELECT CASE lineType
			CASE $function:		lastFuncLine = line
			CASE $constant:		EXIT FOR					' no FUNCTIONs after Constant
		END SELECT
	NEXT line
	IF (lastFuncLine >= 0) THEN							' Insertion point
		IF prog[0,] THEN
			ATTACH prog[0,] TO prolog[]
			uProlog = UBOUND(prolog[])
			insertLine = -1
			FOR line = insertProlog TO uProlog
				ATTACH prolog[line,] TO tok[]
'				IFZ tok[] THEN DO NEXT
				GOSUB CheckTok
				ATTACH tok[] TO prolog[line,]
				SELECT CASE lineType
					CASE $function:		insertLine = line + 1
					CASE $constant:		EXIT FOR			' no FUNCTIONs after Constant
				END SELECT
			NEXT line
			IF (insertLine < 0) THEN insertLine = line
			insertProlog = insertLine
			ATTACH prolog[] TO prog[0,]
		END IF
		GOSUB MergeFunc
		IF (lastFuncLine >= uFunc) THEN GOTO Done
		firstFuncLine	= lastFuncLine + 1
	END IF
'
'	*****  Constant Declarations  *****
'
	lastFuncLine = uFunc
	IF prog[0,] THEN
		ATTACH prog[0,] TO prolog[]
		uProlog = UBOUND(prolog[])
		insertLine = -1
		FOR line = insertProlog TO uProlog
			ATTACH prolog[line,] TO tok[]
'			IFZ tok[] THEN DO NEXT
			GOSUB CheckTok
			ATTACH tok[] TO prolog[line,]
			SELECT CASE lineType
				CASE $constant:		insertLine = line + 1
			END SELECT
		NEXT line
		IF (insertLine >= 0) THEN insertProlog = insertLine
		ATTACH prolog[] TO prog[0,]
	END IF
	GOSUB MergeFunc

Done:
	funcAltered[0] = $$TRUE
	funcNeedsTokenizing[0] = $$FALSE
	programAltered = $$TRUE
	textAlteredSinceLastSave = $$TRUE
	UpdateFileFuncLabels ($$TRUE, $$FALSE)
	SetEntryFunction ()
	IFZ editFunction THEN
		TokenArrayToText (0, @text$[])
		cursorLine	= funcCursorPosition[0, 0]
		cursorPos		= funcCursorPosition[0, 1]
		topLine			= funcCursorPosition[0, 2]
		topIndent		= funcCursorPosition[0, 3]
		XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		XuiSendMessage (xitGrid, #SetTextCursor, cursorPos, cursorLine, topIndent, topLine, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
		funcCursorPosition[0, 0] = cursorLine
		funcCursorPosition[0, 1] = cursorPos
		funcCursorPosition[0, 2] = topLine
		funcCursorPosition[0, 3] = topIndent
		funcCursorPosition[0, 4] = xCursor
		funcCursorPosition[0, 5] = yCursor
	END IF
	RETURN (0)
'
'
'	*****  CheckTok  *****
SUB CheckTok
	lineType = 0
	IFZ tok[] THEN EXIT SUB
	toks = tok[0]{$$BYTE0}
	IF (toks < 2) THEN EXIT SUB
	tokPtr = 1
	IFZ NextXitToken(@tok[], @tokPtr, toks, @t1) THEN EXIT SUB
	SELECT CASE t1
		CASE T_DECLARE, T_INTERNAL, T_EXTERNAL
			IFZ NextXitToken(@tok[], @tokPtr, toks, @token) THEN EXIT SUB
			SELECT CASE token
				CASE  T_FUNCTION, T_CFUNCTION, T_SFUNCTION
				CASE  ELSE:			EXIT SUB
			END SELECT
			DO UNTIL (tokPtr > toks)
				token = tok[tokPtr]
				IF (token{$$KIND} = $$KIND_FUNCTIONS) THEN
					lineType = $function
					EXIT SUB
				END IF
				INC tokPtr
			LOOP
		CASE T_END
			IFZ NextXitToken(@tok[], @tokPtr, toks, @token) THEN EXIT SUB
			IF (token = T_TYPE) THEN lineType = $endType
		CASE ELSE
			IF (t1{$$KIND} = $$KIND_SYSCONS) THEN lineType = $constant
	END SELECT
END SUB
'
'
'	*****  MergeFunc  *****
'		insertProlog	= insertion line in prog[0,]
'											(return: first line after merge)
'		firstFuncLine	= first line in func[]
'		lastFuncLine	= last line in func[]
'
SUB MergeFunc
	newLines = lastFuncLine - firstFuncLine + 1
	IFZ prog[0,] THEN
		DIM prolog[newLines - 1,]
		FOR line = firstFuncLine TO lastFuncLine
			ATTACH func[line,] TO prolog[insertProlog,]
			INC insertProlog
		NEXT line
		ATTACH prolog[] TO prog[0,]
	ELSE
		ATTACH prog[0,] TO prolog[]
		uProlog = UBOUND(prolog[])
		uPrologNew = uProlog + newLines
		REDIM prolog[uPrologNew,]
		IF (insertProlog <= uProlog) THEN				' create gap
			p = uPrologNew
			FOR i = uProlog TO insertProlog STEP -1
				SWAP prolog[i,], prolog[p,]
				DEC p
			NEXT i
		END IF
		FOR line = firstFuncLine TO lastFuncLine
			ATTACH func[line,] TO prolog[insertProlog,]
			INC insertProlog
		NEXT line
		ATTACH prolog[] TO prog[0,]
	END IF
END SUB
END FUNCTION
'
'
' ##############################
' #####  XitNewProgram ()  #####
' ##############################
'
'	Create new PROGRAM.  Erase current source unconditionally.
'
'	In:				none
'	Out:			none
'	Return:		error			0 = no error
'											$$XitEnvironmentInactive
'											$$XitProgramRunning
'
'	Discussion:
'		For external manipulation of environment program (eg GUI)
'
FUNCTION  XitNewProgram ()
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  jump[]
	SHARED  uprog,  environmentActive,  programAltered
	SHARED  xitGrid,  fileType
	SHARED  editFunction,  priorFunction,  textAlteredSinceLastSave
'
	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF ##USERRUNNING THEN RETURN ($$XitProgramRunning)
'
	ResetDataDisplays ($$ResetAssembly)
	ClearRuntimeError ()
	editFunction  = 0													' PROLOG
	priorFunction = 0
	XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
	InitializeCompiler ()				' Initialize compiler arrays/variables

	fileType = $$Program
	programAltered = $$TRUE
	uprog = maxFuncNumber
	DIM prog[uprog,]
	DIM funcAltered[uprog]										' these have same DIM as prog[]
	DIM funcBPAltered[uprog]
	DIM funcNeedsTokenizing[uprog]
	DIM funcCursorPosition[uprog, 5]

	textAlteredSinceLastSave = $$FALSE
	UpdateFileFuncLabels ($$TRUE, $$TRUE)
	DIM jump[25,1]														' Clear jump tags
	RETURN (0)
END FUNCTION
'
'
' #################################
' #####  XitQueryFunction ()  #####
' #################################
'
'	Report if funcName$ currently exists
'
'	In:				funcName$
'	Out:			exists
'	Return:		error			0 = no error
'											$$XitEnvironmentInactive
'											$$XitTextMode
'											$$XitIllegalFunctionName
'	Discussion:
'		For external manipulation of environment program (eg GUI)
'
FUNCTION  XitQueryFunction (funcName$, exists)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  uprog,  fileType,  environmentActive
'
	exists = $$FALSE
	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF (fileType != $$Program) THEN RETURN ($$XitTextMode)
	error = FunctionNameToNumber(@funcName$, @funcNumber)
	IF (error = $$XitIllegalFunctionName) THEN RETURN (error)
	IFZ error THEN exists = $$TRUE
	RETURN (0)
END FUNCTION
'
'
' ################################
' #####  XitQueryProgram ()  #####
' ################################
'
'	Report if current program status
'
'	In:				none
'	Out:			status	bit
'										0				XitActive		0 = not,	1 = active
'										1				mode				0 = Text,	1 = Program
'										2				running			0 = not,	1 = Running
'										3				saved				0 = not,	1 = Saved
'	Return:		0		no error
'
'	Discussion:
'		For external manipulation of environment program (eg GUI)
'
FUNCTION  XitQueryProgram (status)
	SHARED  textAlteredSinceLastSave
	SHARED  environmentActive
	SHARED  fileType
'
	status = 0
	IF environmentActive THEN							status = status OR 0x01
	IF (fileType = $$Program) THEN				status = status OR 0x02
	IF ##USERRUNNING THEN									status = status OR 0x04
	IF NOT textAlteredSinceLastSaved THEN	status = status OR 0x08
	RETURN (0)
END FUNCTION
'
'
' ##############################
' #####  XitSetDECLARE ()  #####
' ##############################
'
' Replace DECLARE line for funcName$ with declare$
'
'	In:				funcName$
'						declare$		Assumes NO NEWLINES
'	Out:			none
' Return:		error				0 no error
'												$$XitEnvironmentInactive
'												$$XitTextMode
'												$$XitProgramRunning
'												$$XitIllegalFunctionName
'												$$XitMismatchedArguments
'	Discussion:
'		Delete it if declare$ empty
'		Add it if funcName$ DECLARE doesn't exist.
'		If editFunction = PROLOG, redisplay.
'
FUNCTION  XitSetDECLARE (funcName$, declare$)
	SHARED  prog[],  funcAltered[],  funcCursorPosition[]
	SHARED  funcNeedsTokenizing[]
	SHARED  xitGrid,  environmentActive,  fileType,  editFunction
	SHARED  programAltered,  textAlteredSinceLastSave
	SHARED  T_DECLARE,  T_EXTERNAL,  T_INTERNAL
	SHARED  T_FUNCTION,  T_CFUNCTION,  T_SFUNCTION
'
	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF (fileType != $$Program) THEN RETURN ($$XitTextMode)
	IF ##USERRUNNING THEN RETURN ($$XitProgramRunning)
	error = FunctionNameToNumber(@funcName$, @funcNumber)
	IF (error = $$XitIllegalFunctionName) THEN RETURN (error)
	IFZ funcNumber THEN RETURN (0)
	IF declare$ THEN
		XxxInitParse ()										' Reset got.function for PROLOG
		XxxParseSourceLine (@declare$, @newTok[])
		isDeclare = CheckDECLARE (@newTok[], @declareFuncNumber)
		IFZ isDeclare THEN RETURN ($$XitMismatchedArguments)
		IF (funcNumber != declareFuncNumber) THEN RETURN ($$XitMismatchedArguments)
	END IF

	IFZ editFunction THEN
		redisplay = $$FALSE								' prepare for PROLOG alterations
		reportBogusRename = $$FALSE
		RestoreTextToProg (redisplay, reportBogusRename)
	END IF
	altered = $$FALSE
	IFZ prog[0,] THEN
		IFZ declare$ THEN RETURN (0)
		XstStringToStringArray (@text$, @text$[])
		TextToTokenArray (@text$[], @func[], 0, 0)
		ATTACH func[] TO prog[0,]
		altered = $$TRUE
	ELSE
		uLine = UBOUND(prog[0,])					' Initialize for FindDECLARE
		line = uLine
		foundDeclare	= $$FALSE						' (not used in remove)
		firstDeclare	= -1
		lastDeclare		= -1
		IFZ declare$ THEN									' remove all funcNumber DECLAREs
			DO
				GOSUB FindDECLARE
				IF (line < 0) THEN EXIT DO
				GOSUB RemoveDECLARE
				altered = $$TRUE
				DEC line
			LOOP
		ELSE
			GOSUB FindDECLARE
			GOSUB AddDECLARE
			altered = $$TRUE
		END IF
	END IF
	IFZ altered THEN RETURN (0)
'
	funcAltered[0] = $$TRUE
	funcNeedsTokenizing[0] = $$FALSE
	programAltered = $$TRUE
	textAlteredSinceLastSave = $$TRUE
	UpdateFileFuncLabels ($$TRUE, $$FALSE)
	SetEntryFunction ()
	IFZ editFunction THEN
		TokenArrayToText (0, @text$[])
		cursorLine	= funcCursorPosition[0, 0]
		cursorPos		= funcCursorPosition[0, 1]
		topLine			= funcCursorPosition[0, 2]
		topIndent		= funcCursorPosition[0, 3]
		XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		XuiSendMessage (xitGrid, #SetTextCursor, cursorPos, cursorLine, topIndent, topLine, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
		funcCursorPosition[0, 0] = cursorLine
		funcCursorPosition[0, 1] = cursorPos
		funcCursorPosition[0, 2] = topLine
		funcCursorPosition[0, 3] = topIndent
		funcCursorPosition[0, 4] = xCursor
		funcCursorPosition[0, 5] = yCursor
	END IF
	RETURN (0)
'
'	FindDECLARE:  same subroutine in XitGetDECLARE
'
'
'	*****  FindDECLARE  *****
'		In:				funcNumber
'							uLine						= UBOUND(prog[0,])
'							line						= start line number (for continuations)
'							foundDeclare		= initialized
'							firstDeclare
'							lastDeclare
'
'		Out:			line					= #   line number of declare for funcNumber
'															-1  not present
'							tokPtr				= token index to func token
'					If not present:
'							foundDeclare	= at least 1 DECLARE exists
'							firstDeclare	= line number of first DECLARE
'							lastDeclare		= line number of last DECLARE
'
'		Discussion:
'			DECLARE and INTERNAL only.  This allows user application to "overwrite"
'				library function.
'
SUB FindDECLARE
	ATTACH prog[0,] TO func[]
	DO UNTIL (line < 0)
		toks = func[line, 0]{$$BYTE0}
		IF (toks < 2) THEN DEC line: DO DO			' newLine
'
		ATTACH func[line,] TO tok[]
'		IFZ tok[] THEN DEC line : DO LOOP
		isDeclare = CheckDECLARE (@tok[], @declareFuncNumber)
		ATTACH tok[] TO func[line,]
		IF isDeclare THEN
			IF (funcNumber = declareFuncNumber) THEN
				ATTACH func[] TO prog[0,]
				EXIT SUB
			END IF
			foundDeclare = $$TRUE
			firstDeclare = line
			IF (lastDeclare < 0) THEN lastDeclare = line
		END IF
		DEC line
	LOOP
	ATTACH func[] TO prog[0,]
END SUB
'
'
'	*****  AddDECLARE  *****
'
SUB AddDECLARE
	IF (line >= 0) THEN											' replace existing line
		SWAP newTok[], prog[0,line,]
		DIM newTok[]
	ELSE
		IF foundDeclare THEN
			declareLine = lastDeclare + 1
		ELSE
			declareLine = uLine + 1
		END IF
		ATTACH prog[0,] TO func[]
		REDIM func[uLine+1,]							' Make room for one more line in PROLOG
		IF (declareLine <= uLine) THEN		' Open slot for new line
			line = uLine
			DO UNTIL (line < declareLine)
				ATTACH func[line,] TO func[line+1,]
				DEC line
			LOOP
		END IF
		ATTACH newTok[] TO func[declareLine,]
		ATTACH func[] TO prog[0,]
	END IF
END SUB
'
'
'	*****  RemoveDECLARE  *****
'
SUB RemoveDECLARE
	ATTACH prog[0,] TO func[]
	IFZ uLine THEN
		DIM func[]
		EXIT SUB
	ELSE
		iline = line
		ATTACH func[line,] TO tok[]:  DIM tok[]
		DO WHILE (iline < uLine)					' compress PROLOG
			ATTACH func[iline+1,] TO func[iline,]
			INC iline
		LOOP
		DEC uLine
		REDIM func[uLine,]
	END IF
	ATTACH func[] TO prog[0,]
END SUB
END FUNCTION
'
'
' ########################################
' #####  XitSetDisplayedFunction ()  #####
' ########################################
'
'	Set currently displayed function
'
'	In:				funcName$
'	Out:			none
'	Return:		error				0 = no error
'												$$XitEnvironmentInactive
'												$$XitTextMode
'												$$XitIllegalFunctionName
'												$$XitFunctionUndefined
'
FUNCTION  XitSetDisplayedFunction (funcName$)
	SHARED  editFunction,  fileType
	SHARED  environmentActive
'
	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF (fileType != $$Program) THEN RETURN ($$XitTextMode)
	error = FunctionNameToNumber(@funcName$, @funcNumber)
	IF error THEN RETURN (error)
'
	Display (funcNumber, -1, -1, -1, -1)
	RETURN (0)
END FUNCTION
'
'
' ###############################
' #####  XitSetFunction ()  #####
' ###############################
'
'	Set function to text$[]
'
'	In:				funcName$
'						text$[]
'	Out:			none
'	Return:		error				0 = no error
'												$$XitEnvironmentInactive
'												$$XitTextMode
'												$$XitProgramRunning
'												$$XitIllegalFunctionName
'												$$XitFunctionUndefined
'
FUNCTION  XitSetFunction (funcName$, text$[])
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  editFunction,  fileType
	SHARED  programAltered,  textAlteredSinceLastSave
	SHARED  environmentActive
	SHARED  xitGrid
'
	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF (fileType != $$Program) THEN RETURN ($$XitTextMode)
	IF ##USERRUNNING THEN RETURN ($$XitProgramRunning)
	error = FunctionNameToNumber(@funcName$, @funcNumber)
	IF (error = $$XitIllegalFunctionName) THEN RETURN (error)
'
	IFZ text$[] THEN															' Delete
		ATTACH prog[funcNumber,] TO func[]:  DIM func[]
		funcAltered[funcNumber]					= $$FALSE		' clear alteration flags
		funcBPAltered[funcNumber]				= $$FALSE
		funcNeedsTokenizing[funcNumber]	= $$FALSE
		funcCursorPosition[funcNumber, 0] = 0				' reset cursorChar / topChar
		funcCursorPosition[funcNumber, 1] = 0
		funcCursorPosition[funcNumber, 2]	= 0
		funcCursorPosition[funcNumber, 3]	= 0
		funcCursorPosition[funcNumber, 4]	= 0
		funcCursorPosition[funcNumber, 5]	= 0

		XxxDeleteFunction (funcNumber)							' Tell compiler
'
'		If removing editFunction, display PROLOG
'
		IF (funcNumber = editFunction) THEN
			TokenArrayToText (0, @text$[])
			cursorLine	= funcCursorPosition[0, 0]
			cursorPos		= funcCursorPosition[0, 1]
			topLine			= funcCursorPosition[0, 2]
			topIndent		= funcCursorPosition[0, 3]
			XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			XuiSendMessage (xitGrid, #SetTextCursor, cursorPos, cursorLine, topIndent, topLine, $$xitTextLower, 0)
			XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
			XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
			XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
			editFunction = 0
			funcCursorPosition[0, 0] = cursorLine
			funcCursorPosition[0, 1] = cursorPos
			funcCursorPosition[0, 2] = topLine
			funcCursorPosition[0, 3] = topIndent
			funcCursorPosition[0, 4] = xCursor
			funcCursorPosition[0, 5] = yCursor
		END IF
		programAltered = $$TRUE
		textAlteredSinceLastSave = $$TRUE
		UpdateFileFuncLabels ($$TRUE, $$TRUE)				' altered
		ResetDataDisplays ($$ResetAssembly)
	ELSE
		freeze = $$TRUE
		TextToTokenArray (@text$[], @func[], funcNumber, freeze)

		ATTACH prog[funcNumber,] TO temp[]					' out with the old...
		DIM temp[]
		ATTACH func[] TO prog[funcNumber,]					' ...in with the new
		funcAltered[funcNumber]					= $$TRUE
		funcBPAltered[funcNumber]				= $$TRUE
		funcNeedsTokenizing[funcNumber]	= $$FALSE
		funcCursorPosition[funcNumber, 0] = 0				' reset cursorChar / topChar
		funcCursorPosition[funcNumber, 1] = 0
		funcCursorPosition[funcNumber, 2]	= 0
		funcCursorPosition[funcNumber, 3]	= 0
		funcCursorPosition[funcNumber, 4]	= 0
		funcCursorPosition[funcNumber, 5]	= 0
		IF (funcNumber = editFunction) THEN
			TokenArrayToText (funcNumber, @text$[])		' convert function to text$
			XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
			XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
		END IF
		programAltered = $$TRUE
		textAlteredSinceLastSave = $$TRUE
		UpdateFileFuncLabels ($$TRUE, $$FALSE)
	END IF
'
	RETURN (0)
END FUNCTION
'
'
' ################################
' #####  XitSaveFunction ()  #####
' ################################
'
'	Save function and its DECLARE to file
'
'	In:				funcName$
'						fileName$
'	Out:			none
'	Return:		error				0 = no error
'												$$XitEnvironmentInactive
'												$$XitTextMode
'												$$XitIllegalFunctionName
'												##ERROR...  (for file operations)
'
FUNCTION  XitSaveFunction (funcName$, fileName$)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[]
	SHARED  saveCRLF
	SHARED  fileType
	SHARED  editFunction
	SHARED  environmentActive
'
	IFZ environmentActive THEN RETURN ($$XitEnvironmentInactive)
	IF (fileType != $$Program) THEN RETURN ($$XitTextMode)
	error = FunctionNameToNumber(@funcName$, @funcNumber)
	IF (error = $$XitIllegalFunctionName) THEN RETURN (error)
'
	IF ((funcNumber = editFunction) AND (NOT ##USERRUNNING)) THEN
		redisplay = $$TRUE
		reportBogusRename = $$TRUE
		RestoreTextToProg (redisplay, reportBogusRename)
	END IF
	DIM text$[0]
	XitGetDECLARE (@funcName$, @declare$)
	IFZ declare$ THEN declare$ = "DECLARE FUNCTION  " + funcName$ + " ()"
	ATTACH declare$ TO text$[0]
	IF prog[funcNumber,] THEN
		ATTACH prog[funcNumber,] TO func[]
		lastLine = UBOUND(func[])
		REDIM text$[lastLine + 1]
		FOR line = 0 TO lastLine
			ATTACH func[line,] TO tok[]
'			IFZ tok[] THEN DO NEXT
			startToken = tok[0]
			tok[0] = startToken AND 0x3FFF00FF		' strip BP/EXE/errno from token line
			XxxDeparser(@tok[], @lineText$)
			tok[0] = startToken										' restore startToken
			ATTACH lineText$ TO text$[line + 1]
			ATTACH tok[] TO func[line,]
		NEXT line
		ATTACH func[] TO prog[funcNumber,]
	END IF
	IF saveCRLF THEN
		error = XstSaveStringArrayCRLF (@fileName$, @text$[])		' \r\n
	ELSE
		error = XstSaveStringArray (@fileName$, @text$[])				' \n
	END IF
	RETURN (error)
END FUNCTION
'
'
' #############################
' #####  XitSoftBreak ()  #####
' #############################
'
' A Soft Break is a Ctrl-Pause.
' It is used as a normal means to break out of the user code execution,
'   returning to the environment.
' It just set breakpoints at every line in the user code and continues
'		allowing the breakpoint to stop the code.  Thus a break becomes a trap
'		and halts at the next line in the USER's code.
'
' Question:  Is there any command that will screw up by never reaching
'		a trap (i.e. a beginning of line)?
'		- All loops are required to be the first on the line, so OK (DO etc)
'		- Systemcalls are a problem:  INC x:  a$ = INLINE$("")
'			- compiler now emits code to check for a softbreak on a signal
'
'		- PROBLEM:  any linked assembly or C code SYSTEMCALLs/loops can hang
'			- SOLUTION:		enter xterm and issue a SIGQUIT
'				- SIGINT is only a softBreak
'				- reinstalling the HardBreak not foolproof if the dispatcher
'						gets hung up in a botched function
'				- having to flip to the xterm is crude...  any ideas?
'			- Recovering from such a break is frought with danger as C/assembly
'					system calls typically don't have code to recover from signals,
'					but continue, skipping the systemcall
'
'	softInterrupt is used to abort find/replace routines
'
FUNCTION  XitSoftBreak ()
	SHARED  softInterrupt
'
	softInterrupt = $$TRUE
	IFZ ##USERRUNNING THEN RETURN									' ignore unless ##USERRUNNING
	IF ##SIGNALACTIVE THEN RETURN
'
	##SOFTBREAK = $$TRUE													' used in SYSTEMCALLs
'	MakeUserCodeRW()															' NT: Not required
	BreakInternal ($$BreakInstallAll, 0, 0, 0)		' Set traps
'	MakeUserCodeRX()															' NT: Not required
END FUNCTION
'
'
' ########################
' #####  XxxAsm$ ()  #####
' ########################
'
FUNCTION  XxxAsm$ (addr, length)
	SHARED	termaddr
'
	IF (length <= 0) THEN length = 0x0080			' prevent negative lengths
	IF (length > 4096) THEN length = 4096			' prevent too long lengths
	IFZ termaddr THEN termaddr = ##CODE
'	addr = addr AND 0xFFFFFFFC								' 32-bit code aligned CPUs
	IFZ addr THEN addr = termaddr
	IFZ AddressOk (addr) THEN
		RETURN ("Invalid start address: " + HEX$(addr, 8))
	END IF
	IF length THEN
		last =  addr + length
	ELSE
		last =  addr + 0x0020
	END IF
	IFZ AddressOk (last) THEN
		IF (last > ##UCODEZ) THEN
			last = ##UCODEZ
		ELSE
			last = ##CODEZ
		END IF
	END IF
	DO WHILE (addr < last)
		labels = XxxGetLabelGivenAddress (addr, @label$[])
		IF labels THEN
			FOR i = 0 TO labels-1
				asm$ = asm$ + HEXX$(addr, 8) + ":   " + label$[i] + ":" + "\r\n"
			NEXT i
		END IF
		asm$ = asm$ + HEXX$(addr, 8) + ":   " + XxxDisassemble$ (@addr, $$TRUE) + "\r\n"
	LOOP
	termaddr = addr
	RETURN (asm$)
END FUNCTION
'#incXitDbg
'
'
' ###########################
' #####  XxxAnyAsm$ ()  #####
' ###########################
'
FUNCTION  XxxAnyAsm$ (addr, length)
	SHARED	termaddr
'
	IF (length <= 0) THEN length = 0x0020			' prevent negative lengths
	IFZ termaddr THEN termaddr = ##CODE
'
'	addr = addr AND 0xFFFFFFFC								' 32-bit code aligned CPUs
'
	IFZ addr THEN addr = termaddr
	last =  addr + length
'
	DO WHILE (addr < last)
		labels = XxxGetLabelGivenAddress (addr, @label$[])
		IF labels THEN
			FOR i = 0 TO labels-1
				asm$ = asm$ + HEXX$(addr, 8) + ":   " + label$[i] + ":" + "\r\n"
			NEXT i
		END IF
		asm$ = asm$ + HEXX$(addr, 8) + ":   " + XxxDisassemble$ (@addr, $$TRUE) + "\r\n"
	LOOP
	termaddr = addr
	RETURN (asm$)
END FUNCTION
'
'
' #########################################
' #####  XxxXitGetUserProgramName ()  #####
' #########################################
'
FUNCTION  XxxXitGetUserProgramName (@program$)
	SHARED  editFilename$
'
	program$ = editFilename$
END FUNCTION
'
'
' ###############################
' #####  XxxSetBlowback ()  #####
' ###############################
'
FUNCTION  XxxSetBlowback ()
	SHARED  blowback
	SHARED	exitMainLoop
'
	SELECT CASE TRUE
		CASE (##USERRUNNING AND (NOT ##SIGNALACTIVE))
					XitSoftBreak()
		CASE ##SIGNALACTIVE
					##SOFTBREAK = $$TRUE			' used in SYSTEMCALLs
	END SELECT
'
	blowback = $$TRUE
	exitMainLoop = $$TRUE
END FUNCTION
'
'
' #############################
' #####  CheckDECLARE ()  #####
' #############################
'
'		Return:		$$TRUE		tok[] is a declare line
'							$$FALSE		it isn't
'
FUNCTION  CheckDECLARE (tok[], declareFuncNumber)
	SHARED  T_DECLARE,  T_INTERNAL,  T_EXTERNAL
	SHARED  T_FUNCTION, T_CFUNCTION,  T_SFUNCTION
'
'	IFZ tok[] THEN RETURN ($$FALSE)
	declareFuncNumber = 0
	toks = tok[0]{$$BYTE0}
	IF (toks < 2) THEN RETURN ($$FALSE)
	tokPtr = 1
	IFZ NextXitToken(@tok[], @tokPtr, toks, @t1) THEN RETURN ($$FALSE)
	SELECT CASE t1
		CASE T_DECLARE, T_INTERNAL
			IFZ NextXitToken(@tok[], @tokPtr, toks, @token) THEN RETURN ($$FALSE)
			SELECT CASE token
				CASE  T_FUNCTION, T_CFUNCTION, T_SFUNCTION
				CASE  ELSE:			RETURN ($$FALSE)
			END SELECT
			DO UNTIL (tokPtr > toks)
				token = tok[tokPtr]
				IF (token{$$KIND} = $$KIND_FUNCTIONS) THEN
					declareFuncNumber = token{$$NUMBER}
					RETURN ($$TRUE)
				END IF
				INC tokPtr
			LOOP
	END SELECT
	RETURN ($$FALSE)
END FUNCTION
'
'
' #############################
' #####  CloneDECLARE ()  #####
' #############################
'
' If DECLARE already exists, leave it
'	IF srcFuncNumber's DECLARE/INTERNAL exists, copy it with newFuncNumber
'	ELSE:  use "DECLARE FUNCTION  funcName ()"
'
FUNCTION  CloneDECLARE (srcFuncNumber, newFuncNumber)
'
	XxxFunctionName ($$XGET, @newFuncName$, newFuncNumber)
	XitGetDECLARE (@newFuncName$, @declare$)
	IF declare$ THEN RETURN
'
	XxxFunctionName ($$XGET, @srcFuncName$, srcFuncNumber)
	XitGetDECLARE (@srcFuncName$, @srcFuncDeclare$)
	declare$ = ""
	IF srcFuncDeclare$ THEN
		XxxParseSourceLine (@srcFuncDeclare$, @tok[])
'		IFZ tok[] THEN RETURN														' disaster !!!
		toks = tok[0]{$$BYTE0}
		FOR i = 1 TO toks
			token = tok[i]
			IF (token{$$KIND} = $$KIND_FUNCTIONS) THEN
				tok[i] = (token AND 0xFFFF0000) OR newFuncNumber
				EXIT FOR
			END IF
		NEXT i
		XxxDeparser(@tok[], @declare$)
	END IF
	IFZ declare$ THEN declare$ = "DECLARE FUNCTION  " + newFuncName$ + " ()"
	XitSetDECLARE (@newFuncName$, @declare$)
END FUNCTION
'
'
' ############################
' #####  CompileLine ()  #####
' ############################
'
'	CompileLine (funcNumber, lineNumber, tok[])
'		If i486bin, then notes the current value of xpc.
'		Compiles line of tokens by calling XxxCheckLine (@tok[], lineNumber).
'		If no error and breakpoint marker is set in tok[0] (START token),
'			then set breakpoint at noted address.
'
' Note:
'		NT: In binary mode, compiler emits a call to XxxCheckMessages() after
'					every DO FOR label: and function entry to handle environment needs.
'					(Look for EmitCheckMessageCall() or XxxCheckMessages in compiler)
'
FUNCTION  CompileLine (funcNumber, lineNumber, tok[])
	EXTERNAL /xxx/  i486bin,  i486asm,  xpc,  maxFuncNumber,  errorCount
	SHARED  lineAddr[],  lineCode[],  lineUpper[],  lineLast[]
	SHARED  funcFirstAddr[],  funcAfterAddr[]
	SHARED  errorXerror[],  errorFunc[],  errorRawPtr[]
	SHARED  errorSrcPtr[],  errorSrcLine$[]
	SHARED  uError,  softInterrupt,  codeSpaceResized
	SHARED  T_FUNCTION,  T_CFUNCTION,  T_SFUNCTION
	SHARED  T_AUTO,  T_AUTOX,  T_STATIC,  T_SHARED,  T_EXTERNAL
'
	SELECT CASE TRUE
		CASE i486bin:  GOSUB CompileLineBinary
		CASE i486asm:  GOSUB CompileLineAssembly
	END SELECT
	RETURN
'
'
' *****  Compile Line into Binary  *****
'
SUB CompileLineBinary
'	IFZ tok[] THEN EXIT SUB
	IF ((##UCODEZ - xpc) < 0x1000) THEN					' Run out of UCODE room?
		currentCodeSize = ##UCODEZ - ##UCODE
		newCodeSize = currentCodeSize + 0x100000	' Add 1Mb
		addr = MakeUserCodeSpace (newCodeSize)
		IFZ addr THEN
			Message (" CompileProgram() \n\n could not allocate memory \n\n abort compile ")
			softInterrupt = $$TRUE
		END IF
		codeSpaceResized = $$TRUE									' restart compilation
		RETURN
	END IF
'
	spc = xpc
	IFZ lineNumber THEN funcFirstAddr[funcNumber] = xpc
'
	xerror = XxxCheckLine (lineNumber, @tok[])
'
'	Minimum is 2 bytes per source line for Win3.1 2-byte breakpoint
'
	IF (xpc = spc + 1) THEN
		UBYTEAT (xpc) = 0x90:  INC xpc				' NOP
	END IF
'
	funcAfterAddr[funcNumber] = xpc					' will end up with "AfterAddr"
	GOSUB LogLineAddrAndCode
'
	IF xerror THEN
		GOSUB LogError
	ELSE
		IF tok[0]{$$BP} THEN BreakProgrammer ($$BreakSetOne, spc, 0)
	END IF
END SUB
'
'
' *****  Compile Line into Assembly  *****
'
SUB CompileLineAssembly
	xerror = XxxCheckLine (lineNumber, @tok[])
'	IFZ tok[] THEN RETURN
	IF xerror THEN GOSUB LogError
END SUB
'
'
'	*****  Log the error into info arrays  *****
'
SUB LogError
	IF (errorCount > 254) THEN													' too many errors...
		softInterrupt = $$TRUE
		EXIT SUB
	END IF
'
'	Get error(s)
'
	IF (funcNumber > maxFuncNumber) THEN								' END PROGRAM
		count = XxxGetPatchErrors (@symbol$[], @token[], @addr[])
		IF (errorCount + count > 255) THEN
			count = 255 - errorCount
		END IF
	ELSE
		count = 1
		XxxErrorInfo (xerror, @rawPtr, @srcPtr, @srcLine$)
	END IF

	IF (errorCount + count >= uError) THEN
		uError = (errorCount + count) << 1
		IF (uError < 31) THEN uError = 31
		IF (uError > 200) THEN uError = 255
		REDIM errorXerror[uError]			' holds error info:  error code
		REDIM errorFunc[uError]				' func number
		REDIM errorRawPtr[uError]			' raw source line 0 offset
		REDIM errorSrcPtr[uError]			' "compressed" source line pointer (offset 1)
		REDIM errorSrcLine$[uError]		' "compressed" source line (no tabs)
	END IF

	IF (funcNumber > maxFuncNumber) THEN								' END PROGRAM
		FOR i = 0 TO count - 1
			INC errorCount
			errorXerror[errorCount]		= xerror
			errorFunc[errorCount]			= -2									' -2 == END PROGRAM
			errorRawPtr[errorCount]		= token[i]
			errorSrcPtr[errorCount]		= addr[i]
			errorSrcLine$[errorCount]	= symbol$[i]
		NEXT i
	ELSE
'
'		Insert the error number into the token
'
		INC errorCount
		startToken = tok[0]
		tok[0] = (startToken AND 0xFFFF00FF) OR (errorCount << 8)
		errorXerror[errorCount]		= xerror
		errorFunc[errorCount]			= funcNumber
		errorRawPtr[errorCount]		= rawPtr
		errorSrcPtr[errorCount]		= srcPtr
		errorSrcLine$[errorCount]	= srcLine$
	END IF
END SUB
'
'
' *****  Log address and opcode for this line in lineAddr[] and lineCode[]
'
SUB LogLineAddrAndCode
	ufunc = UBOUND(lineAddr[])					' Required for function-wise compile only
	IF (maxFuncNumber >= ufunc) THEN
		ufunc = maxFuncNumber + 1					' last is for END PROGRAM
		REDIM lineAddr[ufunc,]
		REDIM lineCode[ufunc,]
		REDIM lineLast[ufunc]
		REDIM lineUpper[ufunc]
		REDIM funcFirstAddr[ufunc]
		REDIM funcAfterAddr[ufunc]
	END IF
	IFZ lineAddr[funcNumber,] THEN
		ATTACH lineAddr[funcNumber,] TO tempAddr[]
		ATTACH lineCode[funcNumber,] TO tempCode[]
		uLine = 15
		DIM tempAddr[uLine]
		DIM tempCode[uLine]
		lineLast[funcNumber] = 0
		lineUpper[funcNumber] = uLine
		ATTACH tempAddr[] TO lineAddr[funcNumber,]
		ATTACH tempCode[] TO lineCode[funcNumber,]
	END IF
	uLine = lineUpper[funcNumber]
	IF (lineNumber >= uLine) THEN
		ATTACH lineAddr[funcNumber,] TO tempAddr[]
		ATTACH lineCode[funcNumber,] TO tempCode[]
		uLine = uLine + 16
		REDIM tempAddr[uLine]
		REDIM tempCode[uLine]
		lineUpper[funcNumber] = uLine
		ATTACH tempAddr[] TO lineAddr[funcNumber,]
		ATTACH tempCode[] TO lineCode[funcNumber,]
	END IF
'
' Log address of line in lineAddr[funcNumber, lineNumber]
' (Note:  opcodes logged into lineCode[funcNumber, lineNumber] during Pass 2)
'
	lineAddr[funcNumber, lineNumber] = spc				' 1st addr for this line
	lineAddr[funcNumber, lineNumber + 1] = xpc		' For last line of function
	lineLast[funcNumber] = lineNumber
END SUB
END FUNCTION
'
'
' ##################################
' #####  ConvertProgToText ()  #####
' ##################################
'
'	Assumes fileType is $$Program
'	Assumes tokens are up to date (editFunction restored)
'
'	RETURNS TRUE if conversion aborted, else FALSE
'		(empty string returned on abort)
'
FUNCTION  ConvertProgToText (mode, crlf, abortAllowed, (text$, text$[]))
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  uprog,  prog[]
	SHARED  funcAltered[],  funcBPAltered[],  funcNeedsTokenizing[]
	SHARED  funcCursorPosition[]
	SHARED  softInterrupt
	SHARED  currentCursor
'
	softInterrupt = $$FALSE
	IF (mode = $$TextArray) THEN
		DIM text$[]
	ELSE
		text$ = ""
	END IF
'
	SetCurrentStatus ($$StatusDeparsing, 0)
	IF (abortAllowed AND softInterrupt) THEN
		RETURN ($$TRUE)
	END IF
'
	entryCursor = currentCursor
'	SetCursor ($$CursorWait)
'
	IF (maxFuncNumber > uprog) THEN						' Sync up in case of crash
		uprog = maxFuncNumber + (maxFuncNumber >> 2)
		REDIM prog[uprog,]
		REDIM funcAltered[uprog]
		REDIM funcBPAltered[uprog]
		REDIM funcNeedsTokenizing[uprog]
		REDIM funcCursorPosition[uprog, 5]
	END IF
'
	SELECT CASE mode
		CASE $$TextString	: GOSUB ConvertToString
		CASE $$TextArray	: GOSUB ConvertToArray
	END SELECT
'	SetCursor (entryCursor)
	RETURN ($$FALSE)
'
'
' *****  ConvertToString  *****
'
SUB ConvertToString
	totalLines = 0
	lastTotal = 0
	totalChars = 0
	DIM textArray$[maxFuncNumber + 1]
	IF crlf THEN flags = 0x03 ELSE flags = 0x01
'
	FOR funcNumber = 0 TO maxFuncNumber
		IFZ prog[funcNumber,] THEN DO NEXT
		ATTACH prog[funcNumber,] TO func[]
		lastLine = UBOUND(func[])
		XxxDeparseFunction (@text$, @func[], lastLine, flags)
		totalChars = totalChars + LEN(text$)
		ATTACH text$ TO textArray$[funcNumber]
		ATTACH func[] TO prog[funcNumber,]
'
		totalLines = totalLines + lastLine + 1
		IF (totalLines > lastTotal + 1024) THEN						' Update every 1024 lines
			lastTotal = totalLines
			SetCurrentStatus ($$StatusDeparsing, totalLines)
			IF (abortAllowed AND softInterrupt) THEN EXIT SUB
		END IF
	NEXT funcNumber
'
	IFZ crlf THEN
		endProgram$ = "END PROGRAM\n"
		text$ = NULL$ (totalChars + 12)											' room for "END PROGRAM\n"
	ELSE
		endProgram$ = "END PROGRAM\r\n"
		text$ = NULL$ (totalChars + 13)											' room for "END PROGRAM\r\n"
	END IF
'
	destAddr = &text$
	textArray$[maxFuncNumber + 1] = endProgram$
'
	offset = 0
	FOR funcNumber = 0 TO maxFuncNumber + 1
		IFZ textArray$[funcNumber] THEN DO NEXT
		srcAddr = &textArray$[funcNumber]
		lastOffset = UBOUND(textArray$[funcNumber])				' offset from 0
		FOR j = 0 TO lastOffset
			UBYTEAT(destAddr, offset) = UBYTEAT(srcAddr, j)
			INC offset
		NEXT j
	NEXT funcNumber
END SUB
'
'
' *****  ConvertToArray  *****
'
SUB ConvertToArray
	lines = 0
	FOR funcNumber = 0 TO maxFuncNumber
		IFZ prog[funcNumber,] THEN DO NEXT
		lines = lines + UBOUND(prog[funcNumber,]) + 1
	NEXT funcNumber
	IFZ lines THEN EXIT SUB
'
	uText = lines + 1																	' Add END PROGRAM
	DIM text$[uText]
'
' Loop through all functions
'
	line = 0
	lastTotal = 0
	FOR funcNumber = 0 TO maxFuncNumber
		IFZ prog[funcNumber,] THEN DO NEXT
		ATTACH prog[funcNumber,] TO func[]
		FOR i = 0 TO UBOUND(func[])
			ATTACH func[i,] TO tok[]
'			IFZ tok[] THEN INC line : DO NEXT
			startToken = tok[0]
			tok[0] = startToken AND 0x3FFF00FF		' strip BP/EXE/errno from token line
			XxxDeparser(@tok[], @lineText$)
			tok[0] = startToken										' restore startToken
'
			ATTACH lineText$ TO text$[line]
			INC line
			ATTACH tok[] TO func[i,]
		NEXT i
		ATTACH func[] TO prog[funcNumber,]
'
		IF (line > lastTotal + 1024) THEN				' Update every 1024 lines
			lastTotal = line
			SetCurrentStatus ($$StatusDeparsing, line)
			IF (abortAllowed AND softInterrupt) THEN
				DIM text$[]
				EXIT SUB
			END IF
		END IF
	NEXT funcNumber
	text$[line] = "END PROGRAM"
END SUB
END FUNCTION
'
'
' ##################################
' #####  ConvertTextToProg ()  #####
' ##################################
'
' Converts source text into prog[func, line, token]
'
'	RETURNS TRUE if aborted, ELSE FALSE
'
'	The upper bound of prog[] is equal to the number of functions in the loaded
'		program.  The upper bound of prog[func] is equal to the number of lines in
'		func[].  The upper bound of prog[func, line] is equal to the number of
'		tokens on the specified line in func[].
'
' ConvertTextToProg() parses source text lines into token arrays, then
'		attaches them to the active func array at the current line number.
'		It switches to the next function when it detects the beginning of the
'		next function--lines beginning with FUNCTION or CFUNCTION and containing a
'		valid function name.
'		To avoid syntax errors, any END FUNCTION in the current function is ignored.
'		When the beginning of the next function is detected, an END FUNCTION is
'		manually inserted after the last non-comment line, any intervening comments
'		are placed at the beginning of the new function, followed by the FUNCTION
'		or CFUNCTION line.
'		Duplicate function definitions are appended to the original function.
'		The PROLOG does not receive an END FUNCTION.  FUNCTION or CFUNCTION lines
'		without a valid function name are considered part of the currently active
'		function.
'		Lines beginning with END or END PROGRAM tokens end the conversion,
'		as does reaching the end of the text.
'
' The PROLOG is named "PROLOG".  The names of all functions following
'		the PROLOG are taken from the FUNCTION or CFUNCTION line.
'
' The index into prog[] is the function number returned from the compiler.
'		As such, prog may contain gaps.
'
' END PROGRAM is eliminated from prog[]
'
'	END CFUNCTION is converted to END FUNCTION.
'
'	Sets the entryFunction
'
'	Discussion:
'		text$[] is mangled
'
FUNCTION  ConvertTextToProg (mode, (text$, text$[]), abortAllowed)
	EXTERNAL /xxx/  maxFuncNumber,  entryFunction
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  UBYTE  charsetNonWhiteChar[]
	SHARED  uprog,  xitGrid,  editFunction,  priorFunction
	SHARED  programAltered,  softInterrupt
	SHARED  maxSharedMemorySize,  maxSharedSegments
	SHARED  sigNumber
	SHARED  T_FUNCTION,  T_CFUNCTION,  T_SFUNCTION
	SHARED  T_END,  T_PROGRAM,  T_COLON,  T_COMMENT
	SHARED  T_DECLARE,  T_INTERNAL
	SHARED  T_VOID,  T_SBYTE,  T_UBYTE,  T_SSHORT,  T_USHORT
	SHARED  T_SLONG,  T_ULONG,  T_XLONG
	SHARED  T_GIANT,	T_SINGLE,  T_DOUBLE,  T_STRING
	SHARED  currentCursor
'
	softInterrupt = $$FALSE
'
	entryCursor = currentCursor
'	SetCursor ($$CursorWait)
'
	programAltered = $$TRUE
	ResetDataDisplays ($$ResetAssembly)
	ClearRuntimeError ()
'
' Initialize arrays
'
	uprog = 127									' uprog updated in Xit to track maxFuncNumber
	DIM prog[uprog,]						' start with room for uprog functions
	uLine = 255
	DIM func[uLine,]						' start with room for uLine lines in PROLOG
'
	InitializeCompiler ()				' Initialize compiler arrays/variables
'
	SetCurrentStatus ($$StatusParsing, totalLines)
	IF (abortAllowed AND softInterrupt) THEN
'		SetCursor (entryCursor)
		RETURN ($$TRUE)
	END IF
'
' Read in lines, look for FUNCTION / END FUNCTION statements
'
	IF (mode = $$TextArray) THEN
		uTextArray = UBOUND(text$[])
		arrayIndex = 0
	END IF
	totalLines			= 0
	lineNumber			= 0
	funcNumber			= 0
	nonCommentLine	= 0
	entryFunction		= 0
	index = 1
	DO UNTIL done
		funcLine = $$FALSE
		endFuncLine = $$FALSE
'
		IF (mode = $$TextArray) THEN
			IF (arrayIndex > uTextArray) THEN EXIT DO
			SWAP text$[arrayIndex], rawLine$
			INC arrayIndex
		ELSE
			rawLine$ = XstNextLine$ (@text$, @index, @done)
			IF done THEN EXIT DO
		END IF
'
		IF rawLine$ THEN														' quick RTRIM non-printables
			IFZ charsetNonWhiteChar[rawLine${UBOUND(rawLine$)}] THEN
				i = UBOUND(rawLine$)
				DO
					DEC i
					IF (i < 0) THEN EXIT DO
				LOOP UNTIL charsetNonWhiteChar[rawLine${i}]
				IF (i < 0) THEN
					rawLine$ = ""
				ELSE
					rawLine${i + 1} = 0										' NULL terminates
					xAddr = &rawLine$											' Ahem...
					XLONGAT (xAddr, -8) = i + 1
				END IF
			END IF
		END IF
		INC totalLines
		XxxParseSourceLine (@rawLine$, @tok[])	' convert source text to token array
'		IFZ tok[] THEN GOTO DoLoop
		startToken = tok[0]											' clear ###>: (error, exe, BP) bits
		tok[0] = startToken AND 0x3FFF00FF

		IF (maxFuncNumber > uprog) THEN
			uprog = maxFuncNumber << 1
			REDIM prog[uprog,]
		END IF
		IF (lineNumber > uLine) THEN					' make room for more lines in func[]
			uLine = uLine << 1
			REDIM func[uLine,]
		END IF
'
' Put blank lines into func[lineNumber,]
'
		toks = startToken{$$BYTE0}					' number of tokens including startToken
		IF (toks <= 1) THEN									' only START token (newline: toks = 0)
			ATTACH tok[] TO func[lineNumber,]
			INC lineNumber
			GOTO DoLoop
		END IF
'
' Put comment lines into func[lineNumber,]
'
		tokPtr = 1
		NextXitToken(@tok[], @tokPtr, toks, @token1)		' Trimmed, so not blank
		IF (token1{$$KIND} = $$KIND_COMMENTS) THEN
			ATTACH tok[] TO func[lineNumber,]
			INC lineNumber
			GOTO DoLoop
		END IF
'
' Non-blank, non-comment lines ...
'
		SELECT CASE token1
			CASE T_FUNCTION		:	funcLine = $$TRUE
			CASE T_CFUNCTION	:	funcLine = $$TRUE
			CASE T_SFUNCTION	:	funcLine = $$TRUE
			CASE T_END
				IF NextXitToken(@tok[], @tokPtr, toks, @token2) THEN
					SELECT CASE token2
						CASE $$ZERO				:	EXIT DO									' END PROGRAM
						CASE T_COLON			:	EXIT DO									' END PROGRAM
						CASE T_PROGRAM		:	EXIT DO									' END PROGRAM
						CASE T_FUNCTION		:	endFuncLine = $$TRUE
						CASE T_CFUNCTION	:	endFuncLine = $$TRUE
						CASE T_SFUNCTION	:	endFuncLine = $$TRUE
					END SELECT
				END IF
		END SELECT
'
		IF endFuncLine THEN													' Ignore END FUNCTION
			DIM endfunctoken[]
			ATTACH tok[] TO endfunctoken[]
			lastNonCommentLine = nonCommentLine
			IF lineNumber THEN nonCommentLine = lineNumber - 1
			GOTO DoLoop
		ELSE
			lastNonCommentLine = nonCommentLine
			nonCommentLine = lineNumber
		END IF

		IF funcLine THEN
'
'			Get FUNCTION name:
'				PROLOG(), though an illegal function name (PASS 1),
'					returns a non-zero function number
'
			DO WHILE NextXitToken(@tok[], @tokPtr, toks, @token)
				SELECT CASE token{$$KIND}
					CASE $$KIND_FUNCTIONS
						nextFuncNumber = token{$$NUMBER}
						EXIT DO
					CASE $$KIND_TYPES					' Skip type name
						DO DO
				END SELECT
				SELECT CASE token
					CASE T_VOID,  T_SBYTE, T_UBYTE, T_SSHORT, T_USHORT, T_SLONG, T_ULONG, T_XLONG
					CASE T_GIANT, T_SINGLE, T_DOUBLE, T_STRING
					CASE ELSE
						EXIT DO
				END SELECT
			LOOP
			IF nextFuncNumber THEN
				XxxFunctionName ($$XGET, @nextFuncName$, nextFuncNumber)
			ELSE
				funcLine = $$FALSE					' no name--stay with this function
			END IF
		END IF
'
' funcNumber = 0 is PROLOG, which takes dIfferent checking
'
		IFZ funcNumber THEN
			SELECT CASE TRUE
				CASE funcLine AND (nextFuncNumber != funcNumber)
					IFZ lineNumber THEN												' Whiz up a PROLOG
						DefaultFunctionText (0, @text$[])
						freeze = $$FALSE
						TextToTokenArray (@text$[], @func[], 0, freeze)
						lineNumber = UBOUND(func[]) + 1
						lastNonCommentLine = lineNumber - 1
					END IF
					lastPrologLine = lineNumber - 1
					GOSUB nextProgramFunc
					funcName$ = nextFuncName$
					funcNumber = nextFuncNumber
					IF (lastNonCommentLine + 1 <= lastPrologLine) THEN
						FOR n = lastNonCommentLine+1 TO lastPrologLine
							ATTACH prog[0,n,] TO func[lineNumber,]
							INC lineNumber
							IF (lineNumber > uLine) THEN
								uLine = uLine << 1
								REDIM func[uLine,]
							END IF
						NEXT n
					END IF
					ATTACH prog[0,] TO temp[]
					REDIM temp[lastNonCommentLine,]
					ATTACH temp[] TO prog[0,]
					ATTACH tok[] TO func[lineNumber,]
					INC lineNumber
					lastNonCommentLine = lineNumber
					nonCommentLine = lineNumber
				CASE ELSE
					IFZ entryFunction THEN							' set entry function
						IF ((token1 = T_DECLARE) OR (token1 = T_INTERNAL)) THEN
							IF NextXitToken(@tok[], @tokPtr, toks, @token) THEN
								SELECT CASE token
									CASE  T_FUNCTION, T_CFUNCTION, T_SFUNCTION
										DO WHILE NextXitToken(@tok[], @tokPtr, toks, @token)
											SELECT CASE token{$$KIND}
												CASE $$KIND_FUNCTIONS
													entryFunction = token{$$NUMBER}
													EXIT DO
												CASE $$KIND_TYPES					' Skip type name
													DO DO
											END SELECT
											SELECT CASE token
												CASE T_VOID,  T_SBYTE, T_UBYTE, T_SSHORT, T_USHORT
												CASE T_SLONG, T_ULONG, T_XLONG
												CASE T_GIANT, T_SINGLE, T_DOUBLE, T_STRING
												CASE ELSE		:	EXIT DO
											END SELECT
										LOOP
								END SELECT
							END IF
						END IF
					END IF
					ATTACH tok[] TO func[lineNumber,]
					INC lineNumber
			END SELECT
		ELSE														' funcNumber is not PROLOG
			SELECT CASE TRUE
				CASE funcLine AND (nextFuncNumber != funcNumber)
					lastFunctionLine = lineNumber - 1
					GOSUB nextProgramFunc
'
'					Transfer trailing comments to next function
'
					IF (lastNonCommentLine + 1 <= lastFunctionLine) THEN
						FOR n = lastNonCommentLine + 1 TO lastFunctionLine
							ATTACH prog[funcNumber, n,] TO func[lineNumber,]
							INC lineNumber
							IF (lineNumber > uLine) THEN
								uLine = uLine << 1
								REDIM func[uLine,]
							END IF
						NEXT n
					END IF
'
'					Attach END FUNCTION, REDIM old function array
'
					IF endfunctoken[] THEN
						upend = UBOUND(endfunctoken[])
						DIM endtok[upend]
						FOR et = 0 TO upend
							endtok[et] = endfunctoken[et]
						NEXT et
					ELSE
						DIM endtok[3]												' last token must be ZERO
						endtok[0] = $$T_STARTS + 3					' start of line token (3 tokens)
						endtok[1] = T_END OR 0x20000000			' add 1 space after end
						endtok[2] = T_FUNCTION							' synthesized line = END FUNCTION
					END IF
'
					line = lastNonCommentLine + 1
					ATTACH prog[funcNumber,] TO oldFunc[]
					ATTACH oldFunc[line,] TO temp[]
					IF temp[] THEN DIM temp[]
					ATTACH endtok[] TO oldFunc[line,]
					REDIM oldFunc[line,]
					ATTACH oldFunc[] TO prog[funcNumber,]
'
'					Set up next function
'
					funcName$ = nextFuncName$
					funcNumber = nextFuncNumber
					ATTACH tok[] TO func[lineNumber,]
					INC lineNumber
					nonCommentLine = lineNumber
					lastNonCommentLine = lineNumber
'
				CASE ELSE
					ATTACH tok[] TO func[lineNumber,]
					INC lineNumber
			END SELECT
		END IF
'
DoLoop:
		SELECT CASE FALSE
			CASE (totalLines AND 0x3FF):	SetCurrentStatus ($$StatusParsing, totalLines)		' Update 1024
			CASE (totalLines AND 0xFF):		ClearMessageQueue ()
		END SELECT
		IF (abortAllowed AND softInterrupt) THEN
'			SetCursor (entryCursor)
			RETURN ($$TRUE)
		END IF
	LOOP
'
' attach last function to prog[], display PROLOG in text widget
'
	IF funcNumber THEN
		IF endfunctoken[] THEN
			upend = UBOUND(endfunctoken[])
			DIM temp[upend]
			FOR et = 0 TO upend
				temp[et] = endfunctoken[et]
			NEXT et
		ELSE
			DIM temp[3]															' Attach END FUNCTION
			temp[0] = $$T_STARTS + 3
			temp[1] = T_END OR 0x20000000
			temp[2] = T_FUNCTION
		END IF
		ATTACH temp[] TO func[lineNumber,]
		INC lineNumber
	END IF
	REDIM func[lineNumber-1,]
	ATTACH func[] TO prog[funcNumber,]				' put last function in prog[]

	IF (uprog > maxFuncNumber + 7) THEN
		uprog = maxFuncNumber + 7
		REDIM prog[uprog,]
	END IF

	DIM funcAltered[uprog]										' these have same DIM as prog[]
	DIM funcBPAltered[uprog]
	DIM funcNeedsTokenizing[uprog]
	DIM funcCursorPosition[uprog, 5]

	FOR funcNumber = 0 TO maxFuncNumber
		IFZ prog[funcNumber,] THEN DO NEXT
		funcAltered[funcNumber] = $$TRUE				' all need compilation
	NEXT funcNumber

	editFunction  = 0													' PROLOG
	priorFunction = 0
	TokenArrayToText (editFunction, @text$[])	' convert PROLOG into source text$
	XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
'	SetCursor (entryCursor)
	RETURN ($$FALSE)
'
'
SUB nextProgramFunc
'
' Put loaded function in prog[], initializes func[]
'		lineNumber points to FUNCTION/CFUNCTION line which is NOT added to current
'			function
'
	ATTACH func[] TO prog[funcNumber,]
	IFZ prog[nextFuncNumber,] THEN
		uLine = 255
		DIM func[uLine,]
		lineNumber = 0
	ELSE
		ATTACH prog[nextFuncNumber,] TO func[]		' Append to existing function
		uLine = UBOUND(func[])
		ATTACH func[uLine,] TO temp[]: DIM temp[]	' Remove END FUNCTION
		lineNumber = uLine												' Next available line number
		uLine = uLine << 1
		REDIM func[uLine,]
	END IF
END SUB
END FUNCTION
'
'
'
' #################################
' #####  DefaultFunctionText  #####
' #################################
'
FUNCTION  DefaultFunctionText (funcNumber, text$[])
'
	IFZ funcNumber THEN		' PROLOG
		DIM text$[25]
		text$[ 0] = "'"
		text$[ 1] = "' ####################"
		text$[ 2] = "' #####  PROLOG  #####  v0.00a"
		text$[ 3] = "' ####################"
		text$[ 4] = "'"
		text$[ 5] = "' Programs contain:  PROLOG             no executable code"
		text$[ 6] = "'                    Entry function     start execution"
		text$[ 7] = "' * = optional       Other functions    everything else"
		text$[ 8] = "'"
		text$[ 9] = "' The PROLOG contains (in this order):"
		text$[10] = "' * 1. Library directives, if any       #library \"libraryName\""
		text$[11] = "' * 2. Composite type definitions       TYPE <typename> ... END TYPE"
		text$[12] = "'   3. Internal function declarations   DECLARE/INTERNAL FUNCTION FuncName (args)"
		text$[13] = "' * 4. External function declarations   EXTERNAL FUNCTION FuncName (args)"
		text$[14] = "' * 5. Shared constant definitions      $$ConstantName = <constant or literal value>"
		text$[15] = "' * 6. Shared variable declarations     SHARED  variable"
		text$[16] = "'"
		text$[17] = "' ******  Comment in libraries as needed  *****"
		text$[18] = "'"
		text$[19] = "'	#library  \"xst\"   ' standard library : required by most programs"
		text$[20] = "'	#library  \"xgr\"   ' GraphicsDesigner : required by GuiDesigner programs"
		text$[21] = "'	#library  \"xui\"   ' GuiDesigner      : required by GuiDesigner programs"
		text$[22] = "'	#library  \"xma\"   ' math library     : SIN/ASIN/SINH/ASINH/LOG/EXP/SQRT..."
		text$[23] = "'	#library  \"xcm\"   ' complex library  : complex number library  (trig, etc)"
		text$[24] = "'"
		text$[25] = "'"
	ELSE
		XxxFunctionName ($$XGET, @funcName$, funcNumber)
		DIM text$[9]
		text$[0] = "'"
		text$[1] = "'"
		text$[2] = "' #######" + CHR$('#', LEN(funcName$)) + "##########"
		text$[3] = "' #####  " +					funcName$					+ " ()  #####"
		text$[4] = "' #######" + CHR$('#', LEN(funcName$)) + "##########"
		text$[5] = "'"
		text$[6] = "FUNCTION  " + funcName$ + " ()"
		text$[7] = ""
		text$[8] = ""
		text$[9] = "END FUNCTION"
	END IF
END FUNCTION
'
'
' ########################
' #####  Display ()  #####
' ########################
'
'	If -1, use old value
'
FUNCTION  Display (funcNumber, cursorLine, cursorPos, topLine, topIndent)
	SHARED  prog[],  fileType
	SHARED  funcCursorPosition[]
	SHARED  editFunction,  priorFunction,  xitGrid
	SHARED  currentCursor
	STATIC	oldFuncNumber
'
	IF (fileType != $$Program) THEN RETURN
	IF (funcNumber < 0) THEN funcNumber = editFunction		' 11/04/93
	XuiSendMessage (xitGrid, #SetKeyboardFocus, 0, 0, 0, 0, $$xitTextLower, 0)
'
' Code added in the next few lines to determine cause of runtime crash in this line:  IFZ prog[funcNumber,] THEN
'
	IF (editFunction != funcNumber) THEN
		IFZ prog[] THEN PRINT "Display() : Error : (prog[] is empty)" : RETURN
		u = UBOUND(prog[])
		IF ((funcNumber < 0) OR (funcNumber > u)) THEN
			PRINT "Display() : Error : (funcNumber ="; funcNumber; "  :  UBOUND(prog[]) ="; u; ")"
			RETURN
		END IF
		IFZ prog[funcNumber,] THEN
			Message (" Display() \n\n no function at # " + STRING$(funcNumber) + " ")
			RETURN
		END IF
'
		entryCursor = currentCursor
'		SetCursor ($$CursorWait)
		TokenArrayToText (funcNumber, @text$[])		' convert function to text$
		redisplay = $$FALSE
		reportBogusRename = $$TRUE								' tokenize, resets BPs
		RestoreTextToProg (redisplay, reportBogusRename)
'
		IF (cursorLine	= -1) THEN cursorLine	= funcCursorPosition[funcNumber, 0]
		IF (cursorPos		= -1) THEN cursorPos	= funcCursorPosition[funcNumber, 1]
		IF (topLine			= -1) THEN topLine		= funcCursorPosition[funcNumber, 2]
		IF (topIndent		= -1) THEN topIndent	= funcCursorPosition[funcNumber, 3]
'
		XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		XuiSendMessage (xitGrid, #SetTextCursor, cursorPos, cursorLine, topIndent, topLine, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
		XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
'
		priorFunction = editFunction
		editFunction  = funcNumber
		funcCursorPosition[editFunction, 0] = cursorLine
		funcCursorPosition[editFunction, 1] = cursorPos
		funcCursorPosition[editFunction, 2] = topLine
		funcCursorPosition[editFunction, 3] = topIndent
		funcCursorPosition[editFunction, 4] = xCursor
		funcCursorPosition[editFunction, 5] = yCursor
		UpdateFileFuncLabels (0, $$TRUE)					' Reset function name
		oldFuncNumber = funcNumber
'		SetCursor (entryCursor)
		RETURN
	END IF
'
	xCursor = -1
	yCursor = -1
	IF ((cursorLine AND cursorPos AND topLine AND topIndent) = -1) THEN
		xCursor = funcCursorPosition[funcNumber, 4]
		yCursor = funcCursorPosition[funcNumber, 5]
	END IF
	IF (cursorLine	= -1) THEN cursorLine	= funcCursorPosition[funcNumber, 0]
	IF (cursorPos		= -1) THEN cursorPos	= funcCursorPosition[funcNumber, 1]
	IF (topLine			= -1) THEN topLine		= funcCursorPosition[funcNumber, 2]
	IF (topIndent		= -1) THEN topIndent	= funcCursorPosition[funcNumber, 3]
'
	XuiSendMessage (xitGrid, #SetTextCursor, cursorPos, cursorLine, topIndent, topLine, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #SetCursorXY, xCursor, yCursor, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
'
	funcCursorPosition[editFunction, 0] = cursorLine
	funcCursorPosition[editFunction, 1] = cursorPos
	funcCursorPosition[editFunction, 2] = topLine
	funcCursorPosition[editFunction, 3] = topIndent
	funcCursorPosition[editFunction, 4] = xCursor
	funcCursorPosition[editFunction, 5] = yCursor
END FUNCTION
'
'
' ##########################
' #####  FindArray ()  #####
' ##########################
'
FUNCTION  FindArray (mode, text$[], find$, line, pos, reps, skip, matches[])
'
	IF (mode AND 0x01) THEN dir = -1 ELSE dir = +1
	slot = -1
	upper = 255
	DIM matches[upper,1]
	lp = line : cp = pos
	IF skip THEN cp = cp + dir
'
	DO WHILE reps
		XstFindArray (mode, @text$[], @find$, @lp, @cp, @match)
		IF match THEN
			INC slot
			DEC reps
			IF (slot > upper) THEN upper = slot + 256 : REDIM matches[upper,1]
			matches[slot,0] = lp
			matches[slot,1] = cp
			cp = cp + dir
		END IF
	LOOP WHILE match
	IF (slot < 0) THEN
		DIM matches[]
	ELSE
		line = lp
		pos = cp - dir
		REDIM matches[slot,1]
	END IF
END FUNCTION
'
'
' #####################################
' #####  FunctionNameToNumber ()  #####
' #####################################
'
'	Test function name for validity, return funcNumber
'
'	In:				funcName$
'	Out:			funcNumber
'	Return:		error			0 = valid
'											$$XitIllegalFunctionName
'											$$XitFunctionUndefined
'
'	Discussion:
'		Assumes environmentActive, ProgramMode
'
FUNCTION  FunctionNameToNumber (funcName$, funcNumber)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  uprog

	IFZ funcName$ THEN RETURN ($$XitIllegalFunctionName)
	cchar = funcName${0}
	IF ((cchar >= '0') AND (cchar <= '9')) THEN RETURN ($$XitIllegalFunctionName)
	lastChar = UBOUND(funcName$)
	FOR i = 0 TO lastChar
		cchar = funcName${i}
		IF ((cchar >= 'a') AND (cchar <= 'z')) THEN DO NEXT
		IF ((cchar >= 'A') AND (cchar <= 'Z')) THEN DO NEXT
		IF ((cchar >= '0') AND (cchar <= '9')) THEN DO NEXT
		IF (cchar = '_') THEN DO NEXT
		IF (cchar = '$') THEN									' only explicit type is STRING
			IF (i = lastChar) THEN EXIT FOR
		END IF
		RETURN ($$XitIllegalFunctionName)
	NEXT i

	IF (funcName$ = "PROLOG") THEN
		funcNumber = 0
	ELSE
		token$ = funcName$ + " ("									' compiler assigns function number
		XxxParseSourceLine (@token$, @tok[])
		IF (maxFuncNumber > uprog) THEN
			uprog = maxFuncNumber + (maxFuncNumber >> 2)
			REDIM prog[uprog,]
			REDIM funcAltered[uprog]
			REDIM funcBPAltered[uprog]
			REDIM funcNeedsTokenizing[uprog]
			REDIM funcCursorPosition[uprog, 5]
		END IF
		funcNumber = tok[1]{$$NUMBER}
	END IF
	IFZ prog[funcNumber,] THEN RETURN ($$XitFunctionUndefined)
	RETURN (0)
END FUNCTION
'
'
' ##########################################
' #####  GetFuncNumberGivenAddress ()  #####
' ##########################################
'
FUNCTION  GetFuncNumberGivenAddress (addr)
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  funcFirstAddr[],  funcAfterAddr[]

	IFZ funcFirstAddr[] THEN RETURN (-1)
	IFZ funcAfterAddr[] THEN RETURN (-1)

	funcNumber = 0
	DO WHILE (funcNumber <= maxFuncNumber)
		IFZ prog[funcNumber,] THEN INC funcNumber: DO DO
		firstAddr = funcFirstAddr[funcNumber]
		afterAddr = funcAfterAddr[funcNumber]
		IF ((firstAddr <= addr) AND (addr < afterAddr)) THEN RETURN (funcNumber)
		INC funcNumber
	LOOP
	RETURN (-1)
END FUNCTION
'
'
' ##########################
' #####  SetCursor ()  #####
' ##########################
'
'	Change the cursor in each Xit widget
'
'	In:				cursorID			new X-Windows cursor ID
'	Out:			none					arg unchanged
'	Return:		none
'
FUNCTION  SetCursor (cursorID)
	SHARED  popupGrids[]
	SHARED  currentCursor

	IF (cursorID = currentCursor) THEN RETURN
	currentCursor = cursorID

	FOR i = 0 TO UBOUND(popupGrids[])
		grid = popupGrids[i]
		IF grid THEN
			XgrGetGridWindow (grid, @window)	'xxx
'			XgrSetWindowCursor (window, cursor)	'xxx
		END IF
	NEXT i
END FUNCTION
'
'
' ###################################
' #####  InitializeCompiler ()  #####
' ###################################
'
FUNCTION  InitializeCompiler ()
	SHARED  T_DECLARE,  T_INTERNAL,  T_EXTERNAL
	SHARED  T_FUNCTION,  T_CFUNCTION,  T_SFUNCTION
	SHARED  T_END,  T_TYPE,  T_PROGRAM
	SHARED  T_COLON,  T_COMMENT,  T_DIV
	SHARED  T_AUTO,  T_AUTOX,  T_STATIC,  T_SHARED
	SHARED  T_VOID,  T_SBYTE,  T_UBYTE,  T_SSHORT,  T_USHORT
	SHARED	T_SLONG,  T_ULONG,  T_XLONG
	SHARED  T_GIANT,	T_SINGLE,  T_DOUBLE,  T_STRING
	STATIC  notFirstPass

	SetCurrentStatus ($$StatusInitializing, 0)
	XxxInitAll ()									' Initialize compiler arrays/variables/tokens

	IF notFirstPass THEN RETURN
	notFirstPass = $$TRUE
'
' Define some useful tokens
'
	tokens$ = "DECLARE INTERNAL EXTERNAL FUNCTION CFUNCTION SFUNCTION"
	tokens$ = tokens$ + " END TYPE PROGRAM : /"
	tokens$ = tokens$ + " AUTO AUTOX STATIC SHARED"
	tokens$ = tokens$ + " VOID SBYTE UBYTE SSHORT USHORT SLONG ULONG XLONG"
	tokens$ = tokens$ + " GIANT SINGLE DOUBLE STRING ' xxx"
	XxxParseSourceLine (tokens$, @tok[])
	i = 1
	T_DECLARE		= tok[i] {$$CLEAR_SPACE}:		INC i
	T_INTERNAL	= tok[i] {$$CLEAR_SPACE}:		INC i
	T_EXTERNAL	= tok[i] {$$CLEAR_SPACE}:		INC i
	T_FUNCTION	= tok[i] {$$CLEAR_SPACE}:		INC i
	T_CFUNCTION	= tok[i] {$$CLEAR_SPACE}:		INC i
	T_SFUNCTION	= tok[i] {$$CLEAR_SPACE}:		INC i
	T_END				= tok[i] {$$CLEAR_SPACE}:		INC i
	T_TYPE			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_PROGRAM		= tok[i] {$$CLEAR_SPACE}:		INC i
	T_COLON			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_DIV				= tok[i] {$$CLEAR_SPACE}:		INC i
	T_AUTO			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_AUTOX			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_STATIC		= tok[i] {$$CLEAR_SPACE}:		INC i
	T_SHARED		= tok[i] {$$CLEAR_SPACE}:		INC i
	T_VOID			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_SBYTE			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_UBYTE			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_SSHORT		= tok[i] {$$CLEAR_SPACE}:		INC i
	T_USHORT		= tok[i] {$$CLEAR_SPACE}:		INC i
	T_SLONG			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_ULONG			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_XLONG			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_GIANT			= tok[i] {$$CLEAR_SPACE}:		INC i
	T_SINGLE		= tok[i] {$$CLEAR_SPACE}:		INC i
	T_DOUBLE		= tok[i] {$$CLEAR_SPACE}:		INC i
	T_STRING		= tok[i] {$$CLEAR_SPACE}:		INC i
	T_COMMENT		= tok[i] {$$CLEAR_SPACE}:		INC i
END FUNCTION
'
'
' ##################################
' #####  LoadLineCodeArray ()  #####
' ##################################
'
' LoadLineCodeArray ()
'   After programs are compiled to executable binary in memory, the 1st opcode
'   on each line must be logged into lineCode[].  The address of the first
'   opcode on each line is found in lineAddr[].  Note that this must be done
'   after complete compilation (not within CompileLine() for example), because
'   some opcodes are not complete until PASS 2 completes, because PASS 2
'   patches several kinds of incomplete opcodes, including foreward references.
'
'	NT:  "opcode" refers to the FIRST BYTE of the opcode.  It simply needs to
'					be the length of the $$BREAK instruction (1 byte).
'				(#WINLESS = 2 byte)
'
FUNCTION  LoadLineCodeArray ()
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  prog[],  lineAddr[],  lineCode[],  lineLast[]

	funcNumber = 0
	DO UNTIL (funcNumber > maxFuncNumber)
		IFZ prog[funcNumber,] THEN INC funcNumber: DO DO

		lineLast = lineLast[funcNumber]
		line = 0
		DO UNTIL (line > lineLast)
			lineAddr = lineAddr[funcNumber, line]
'			lineCode = XLONGAT (lineAddr)								' 88k: Break is XLONG
			IFZ #WINLESS THEN
				lineCode = UBYTEAT (lineAddr)							' NT 1 byte
			ELSE
				lineCode = USHORTAT (lineAddr)							' NT 2 byte
			END IF
			lineCode[funcNumber, line] = lineCode
			INC line
		LOOP
		INC funcNumber
	LOOP
END FUNCTION
'
'
' #############################
' #####  NextXitToken ()  #####
' #############################
'
'	Return:  $$FALSE if no meaty tokens remaining (done)
'
FUNCTION  NextXitToken (tok[], tokPtr, lastTok, token)
'
'	IFZ tok[] THEN RETURN ($$FALSE)
'	upper = UBOUND(tok[])
'	IF (upper < lastTok) THEN lastTok = upper
'
	DO WHILE (tokPtr <= lastTok)
		token = tok[tokPtr]{$$CLEAR_SPACE}
		INC tokPtr
		kind = token{$$KIND}
		IF (kind != $$KIND_WHITES) THEN
			IF (kind = $$KIND_COMMENTS) THEN
				RETURN ($$FALSE)
			ELSE
				RETURN ($$TRUE)
			END IF
		END IF
	LOOP
	RETURN ($$FALSE)
END FUNCTION
'
'
' #################################
' #####  RemoveExeLinePtr ()  #####
' #################################
'
FUNCTION  RemoveExeLinePtr ()
	SHARED  prog[]
	SHARED  editFunction,  exeFunction,  exeLine,  xitGrid
'
	IFZ exeFunction THEN GOTO done
	IFZ prog[exeFunction,] THEN GOTO done
	ATTACH prog[exeFunction,] TO func[]
	IF (exeLine <= UBOUND(func[])) THEN
		func[exeLine, 0] = func[exeLine,0] AND 0xBFFFFFFF		' waste >
		IF (exeFunction = editFunction) THEN
			XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
			IF text$[] THEN
				modified = $$FALSE
				FOR line = 0 TO UBOUND(text$[])
					IFZ text$[line] THEN DO NEXT
					IF (text$[line]{0} = '>') THEN
						text$[line] = MID$(text$[line], 2)
						modified = $$TRUE
					END IF
				NEXT line
				XuiSendMessage (xitGrid, #PokeTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
				IF modified THEN
					XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
				END IF
			END IF
		END IF
	END IF
	ATTACH func[] TO prog[exeFunction,]

done:
	exeFunction = 0
	exeLine = 0
END FUNCTION
'
'
' #############################
' #####  ReplaceArray ()  #####
' #############################
'
FUNCTION  ReplaceArray (mode, text$[], find$, replace$, line, pos, reps, skip)
'
	dir = 1
	reverse = $$FALSE
	IF (mode AND 0x01) THEN dir = -1 : reverse = $$TRUE
	mached = $$FALSE
	lp = line : cp = pos
	length = LEN (replace$)
	IF skip THEN cp = cp + dir
	upper = UBOUND (text$[])
	IF (cp < 0) THEN
		lp = lp - 1
		IF (lp < 0) THEN lp = upper
		t$ = text$[lp]
		cp = LEN (t$)
	END IF
'
	DO WHILE reps
		XstReplaceArray (mode, @text$[], @find$, @replace$, @lp, @cp, @match)
		IF match THEN
			IFZ reverse THEN cp = cp + length
			mached = $$TRUE
			DEC reps
		END IF
	LOOP WHILE match
	IF mached THEN pos = cp : line = lp
END FUNCTION
'
'
' ##################################
' #####  ResetDataDisplays ()  #####
' ##################################
'
'	action{1,0} = reset the assembly window
'				{1,1} = initiating run
'
FUNCTION  ResetDataDisplays (action)
	SHARED  variableFuncRow[]
	SHARED  programAltered,  fileType
	SHARED  assemblyBox,  framesBox
	SHARED  variableUp,  variableBox
	SHARED  arrayUp,  arrayBox
	SHARED  stringUp,  stringBox,  compositeUp,  compositeBox
	SHARED  exeFunction
'
	$RESET_ASSEMBLY = BITFIELD (1, 0)
	$INITIATING_RUN  = BITFIELD (1, 1)
'
	IF exeFunction THEN RemoveExeLinePtr()					' waste >
'
	IF action{$RESET_ASSEMBLY} THEN
		justUpdate = $$TRUE
		DebugAssembly (assemblyBox, #DisplayWindow, justUpdate, 0, 0, 0, 0, 0)
	END IF
'
	SELECT CASE TRUE
		CASE (fileType != $$Program)
					unavailable$ = "* Unavailable: TEXT mode *"
					DIM variableFuncRow[]
		CASE programAltered							' TextModify doesn't reset ##USERRUNNING
					unavailable$ = "* Program requires compilation *"
					DIM variableFuncRow[]
		CASE action{$INITIATING_RUN}
					unavailable$ = "* Program executing *"
		CASE (##USERRUNNING AND (NOT ##SIGNALACTIVE))
					unavailable$ = "* Program executing *"
		CASE ELSE												' not ##USERRUNNING or ???
					unavailable$ = "* Program not running *"
	END SELECT
'
	IF variableFuncRow[] THEN
		func = variableFuncRow[0, 0]		' PROLOG slot used for current func
		IF func THEN										' top character / cursor
			XuiSendMessage (variableBox, #GetTextCursor, 0, @cursorLine, 0, @topLine, 3, 0)
			variableFuncRow[func, 0] = topLine
			variableFuncRow[func, 1] = cursorLine
		END IF
		variableFuncRow[0, 0] = 0				' Say last function = PROLOG
	END IF
'
' Max: During FileLoad, XuiSendMessage() gets "(grid <= 0)" error below
'
	IF (framesBox <= 0) THEN PRINT "ResetDataDisplays() : Error : (framesBox <= 0) "; framesBox
'
'	Frames:
'
	DIM item$[0]
	item$[0] = unavailable$
	XuiSendMessage (framesBox, #SetTextArray, 0, 0, 0, 0, 2, @item$[])
	XuiSendMessage (framesBox, #SetTextCursor, 0, 0, 0, 0, 2, 0)
	XuiSendMessage (framesBox, #RedrawText, 0, 0, 0, 0, 2, 0)
'
'	Variables:
'
	DIM text$[0]
	text$[0] = unavailable$
	XuiSendMessage (variableBox, #SetTextArray, 0, 0, 0, 0, 3, @text$[])
	XuiSendMessage (variableBox, #SetTextCursor, 0, 0, 0, 0, 3, 0)
	XuiSendMessage (variableBox, #RedrawText, 0, 0, 0, 0, 3, 0)
	XuiSendMessage (variableBox, #SetTextString, 0, 0, 0, 0, 1, "")
	XuiSendMessage (variableBox, #RedrawGrid, 0, 0, 0, 0, 1, 0)
	XuiSendMessage (variableBox, #SetTextString, 0, 0, 0, 0, 7, "")
	XuiSendMessage (variableBox, #RedrawText, 0, 0, 0, 0, 7, 0)
	IF arrayUp THEN VariablesArray (arrayBox, #HideWindow, 0, 0, 0, 0, 0, 0)
	IF stringUp THEN VariablesString (stringBox, #HideWindow, 0, 0, 0, 0, 0, 0)
	IF compositeUp THEN	VariablesComposite (compositeBox, #HideWindow, 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' ##################################
' #####  RestoreTextToProg ()  #####
' ##################################
'
'	Note:  User not allowed to rename or remove a function by editing
'					(attempts are overridden).  Use Menu functions.
'
' TextModify determines differences
'
' Tokenize the text
'		- Tokenizing discards trailing newlines, removes currentexe/BP from PROLOG,
'				and RTRIMs each line
'
FUNCTION  RestoreTextToProg (redisplay, reportBogusRename)
	SHARED  prog[]
	SHARED  funcBPAltered[],  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  editFunction,  xitGrid
	SHARED  currentCursor
'
'	Always reset current cursor location, top character (prep for changing text)
'
	XuiSendMessage (xitGrid, #GetTextCursor, @cursorPos, @cursorLine, @topIndent, @topLine, $$xitTextLower, 0)
	XuiSendMessage (xitGrid, #GetCursorXY, @xCursor, @yCursor, 0, 0, $$xitTextLower, 0)
	funcCursorPosition[editFunction, 0] = cursorLine
	funcCursorPosition[editFunction, 1] = cursorPos
	funcCursorPosition[editFunction, 2] = topLine
	funcCursorPosition[editFunction, 3] = topIndent
	funcCursorPosition[editFunction, 4] = xCursor
	funcCursorPosition[editFunction, 5] = yCursor
'
	IFZ funcNeedsTokenizing[editFunction] THEN			' No text changes
		IFZ funcBPAltered[editFunction] THEN RETURN		' No BP changes
'
'		Update BP list
'
		IFZ prog[editFunction,] THEN RETURN									' Nothing to do
		XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		IFZ text$[] THEN RETURN

		ATTACH prog[editFunction,] TO func[]
		ufunc = UBOUND(func[])
		IF (ufunc != UBOUND(text$[])) THEN
			Message (" RestoreTextToProgram() \n\n internal error \n\n editFunction not in sync with prog ")
			RETURN
		END IF
		FOR line = 0 TO ufunc
			startToken = func[line,0]
			IFZ text$[line] THEN
				func[line,0] = startToken{$$CLEAR_BP_EXE}
				DO NEXT
			END IF

			cchar = text$[line]{0}
			SELECT CASE TRUE
				CASE (cchar = '>')															' >?
					IF (LEN(text$[line]) < 2) THEN
						func[line,0] = startToken{$$CLEAR_BP_EXE}
						DO NEXT
					END IF
					cchar = text$[line]{1}

				CASE (('0' <= cchar) AND (cchar <= '9'))				' errorCode?
					IF (LEN(text$[line]) < 4) THEN
						func[line,0] = startToken{$$CLEAR_BP_EXE}
						DO NEXT
					END IF
					cchar = text$[line]{3}
			END SELECT

			IF (cchar = ':') THEN
				func[line,0] = startToken OR 0x80000000		' Set BP bit
			ELSE
				func[line,0] = startToken{$$CLEAR_BP}			' Clear BP bit
			END IF
		NEXT line

		ATTACH func[] TO prog[editFunction,]
		XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
		XuiSendMessage (xitGrid, #SetTextCursor, cursorPos, cursorLine, topIndent, topLine, $$xitTextLower, 0)
		funcBPAltered[editFunction] = $$FALSE
		RETURN
	END IF
'
	entryCursor = currentCursor
'	SetCursor ($$CursorWait)
'
' Function needs tokenizing
'
	XuiSendMessage (xitGrid, #GetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	IFZ TextHasNonWhites ($$TextArray, @text$[]) THEN			' fix empty
		DefaultFunctionText (editFunction, @text$[])
	END IF
	freeze = $$TRUE
	bogusFunction = TextToTokenArray (@text$[], @func[], editFunction, freeze)
	ATTACH prog[editFunction,] TO temp[]						' out with the old...
	ATTACH func[] TO prog[editFunction,]						'   ...in with the new
	TokenArrayToText (editFunction, @text$[])				' sync text with tokens
	XuiSendMessage (xitGrid, #SetTextArray, 0, 0, 0, 0, $$xitTextLower, @text$[])
	XuiSendMessage (xitGrid, #SetTextCursor, cursorPos, cursorLine, topIndent, topLine, $$xitTextLower, 0)
	IF redisplay THEN
		XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
	END IF
	funcBPAltered[editFunction] = $$FALSE
	funcNeedsTokenizing[editFunction] = $$FALSE
	IF (bogusFunction AND reportBogusRename) THEN
		XxxFunctionName ($$XGET, @funcName$, editFunction)
		Message (" RestoreTextToProgram() \n\n function not renamed \n\n try ViewRenameFunction " + funcName$ + " ")
	END IF
'	SetCursor (entryCursor)
END FUNCTION
'
'
' #################################
' #####  SetCurrentStatus ()  #####
' #################################
'
FUNCTION  SetCurrentStatus (status, line)
	EXTERNAL /xxx/ errorCount, library
	SHARED  xitGrid
	SHARED  currentStatus
	STATIC  currentErrorCount
'
	IF (errorCount != currentErrorCount) THEN
		newError = $$TRUE
		IFZ errorCount THEN
			error$ = "status/errors"
			UpdateErrors (0, 0)
		ELSE
			error$ = "errors: " + RJUST$(STRING$(errorCount), 7)
		END IF
		XuiSendMessage (xitGrid, #SetTextString, 0, 0, 0, 0, $$xitErrorLabel, @error$)
		XuiSendMessage (xitGrid, #RedrawGrid, 0, 0, 0, 0, $$xitErrorLabel, 0)
		currentErrorCount = errorCount
	END IF
'
	newStatus = $$TRUE
	IFZ line THEN
		IF (status = currentStatus) THEN newStatus = $$FALSE
	END IF
'
	IFZ (newError OR newStatus) THEN RETURN
	IFZ newStatus THEN GOTO ShowChanges
'
	currentStatus = status
	SELECT CASE currentStatus
		CASE  $$StatusAssembling	: IF library THEN
																	status$ = "compile lib"
																ELSE
																	status$ = "compile asm"
																END IF
		CASE $$StatusCompiled			: status$ = "compiled"
		CASE $$StatusCompiling		: status$ = "compiling  "
		CASE $$StatusDecoding			: status$ = "decoding   "
		CASE $$StatusDeparsing		: status$ = "deparsing  "
		CASE $$StatusFormatting		: status$ = "formatting "
		CASE $$StatusInitializing	: status$ = "initializing"
		CASE $$StatusLoading			: status$ = "loading"
		CASE $$StatusParsing			: status$ = "parsing    "
		CASE $$StatusPaused				: status$ = "paused"
		CASE $$StatusRecompiling	: status$ = "recompiling"
		CASE $$StatusRunning			: status$ = "running"
		CASE $$StatusSaving				: status$ = "saving"
		CASE $$StatusSearching		: status$ = "searching  "
		CASE $$StatusInline				: status$ = "waiting INLINE$()"
		CASE ELSE									: status$ = " "
	END SELECT
'
'	Parsing, Deparsing, Compiling, Recompiling, Assembling, Decoding:  add line
'
	IF line THEN
		SELECT CASE currentStatus
			CASE $$StatusDecoding,  $$StatusFormatting,  $$StatusSearching
				IF (line < 10000) THEN
					status$ = status$ + RJUST$(STRING$(line), 4)
					GOTO ShowStatus
				END IF
		END SELECT

		SELECT CASE TRUE
			CASE (line < 1000000)
				line = line >> 10																		' divide by 1K
				status$ = status$ + RJUST$(STRING$(line), 3) + "K"
			CASE ELSE:
				line = line >> 20																		' divide by 1M
				status$ = status$ + RJUST$(STRING$(line), 3) + "M"
		END SELECT
	END IF

ShowStatus:
	XuiSendMessage (xitGrid, #SetTextString, 0, 0, 0, 0, $$xitStatusLabel, @status$)
	XuiSendMessage (xitGrid, #RedrawGrid, 0, 0, 0, 0, $$xitStatusLabel, 0)
'
ShowChanges:
	ClearMessageQueue ()
END FUNCTION
'
'
' ################################
' #####  SetDataDisplays ()  #####
' ################################
'
' Frames updated elsewhere
'
FUNCTION  SetDataDisplays ()
	SHARED  assemblyBox,  registerBox
'
	justUpdate = $$TRUE
	DebugAssembly (assemblyBox, #DisplayWindow, justUpdate, 0, 0, 0, 0, 0)
	DebugRegisters (registerBox, #DisplayWindow, justUpdate, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' #################################
' #####  SetEntryFunction ()  #####
' #################################
'
FUNCTION  SetEntryFunction ()
	EXTERNAL /xxx/  entryFunction
	SHARED  prog[]
	SHARED  T_DECLARE,  T_INTERNAL,  T_EXTERNAL
	SHARED  T_FUNCTION, T_CFUNCTION,  T_SFUNCTION

	entryFunction = 0
	IFZ prog[] THEN RETURN
	IFZ prog[0,] THEN RETURN
	ATTACH prog[0,] TO func[]
	FOR line = 0 TO UBOUND(func[])
		ATTACH func[line,] TO tok[]
		IFZ tok[] THEN GOTO nextLine
		toks = tok[0]{$$BYTE0}
		IF (toks < 2) THEN GOTO nextLine
		tokPtr = 1
		IFZ NextXitToken(@tok[], @tokPtr, toks, @t1) THEN GOTO nextLine
		SELECT CASE t1
			CASE T_DECLARE, T_EXTERNAL, T_INTERNAL
				IFZ NextXitToken(@tok[], @tokPtr, toks, @token) THEN GOTO nextLine
				SELECT CASE token
					CASE  T_FUNCTION, T_CFUNCTION, T_SFUNCTION
					CASE  ELSE:			GOTO nextLine
				END SELECT
				DO UNTIL (tokPtr > toks)
					token = tok[tokPtr]
					IF (token{$$KIND} = $$KIND_FUNCTIONS) THEN
						entryFunction = token{$$NUMBER}
						ATTACH tok[] TO func[line,]
						EXIT FOR
					END IF
					INC tokPtr
				LOOP
		END SELECT
nextLine:
		ATTACH tok[] TO func[line,]
	NEXT line
	ATTACH func[] TO prog[0,]
END FUNCTION
'
'
' ##############################
' #####  SetExeLinePtr ()  #####
' ##############################
'
FUNCTION  SetExeLinePtr ()
	SHARED  prog[]
	SHARED  exeFunction,  exeLine,  xitGrid,  editFunction
'
	IFZ exeFunction THEN RETURN
	IFZ prog[exeFunction,] THEN RETURN

	ATTACH prog[exeFunction,] TO func[]
	IF (exeLine <= UBOUND(func[])) THEN
		startToken = func[exeLine, 0]
		IFZ startToken{$$EXE} THEN
			func[exeLine, 0] = startToken OR 0x40000000			' set >
			IF (exeFunction = editFunction) THEN
				XuiSendMessage (xitGrid, #TextReplace, 0, exeLine, 0, exeLine, $$xitTextLower, @">")
				XuiSendMessage (xitGrid, #RedrawText, 0, 0, 0, 0, $$xitTextLower, 0)
			END IF
		END IF
	END IF
	ATTACH func[] TO prog[exeFunction,]
END FUNCTION
'
'
' ##################################
' #####  SortFunctionNames ()  #####
' ##################################
'
'	return number of function names in name$[]
'	PROLOG is always first, Entry() is always second, the rest are in alphabetic order
'
FUNCTION  SortFunctionNames (name$[], includePROLOG)
	EXTERNAL /xxx/  maxFuncNumber,  entryFunction
	SHARED  prog[]
'
	DIM name$[maxFuncNumber]
	IF includePROLOG THEN
		name$[0] = "PROLOG"
		IFZ maxFuncNumber THEN
			REDIM name$[0]
			RETURN (1)
		END IF
		item = 1															' PROLOG is #1
		startSortItem = 2
	ELSE
		IFZ maxFuncNumber THEN
			DIM name$[]
			RETURN (0)
		END IF
		item = 0
		startSortItem = 1
	END IF
'
	IF entryFunction THEN										' Entry function is first
		IF prog[entryFunction,] THEN					' (only if it is defined)
			XxxFunctionName ($$XGET, @funcName$, entryFunction)
			IF funcName$ THEN
				ATTACH funcName$ TO name$[item]
				INC item
				INC startSortItem
			END IF
		END IF
	END IF
'
	XxxPassFunctionArrays ($$XGET, @funcSymbol$[], @funcToken[], @funcScope[])
	func = 1																' skip PROLOG
	DO UNTIL (func > maxFuncNumber)
		IFZ prog[func,] THEN INC func: DO DO
		IF (func = entryFunction) THEN INC func: DO DO
		name$[item] = funcSymbol$[func]
		INC func
		INC item
	LOOP
	XxxPassFunctionArrays ($$XSET, @funcSymbol$[], @funcToken[], @funcScope[])
	IFZ item THEN
		DIM name$[]
		RETURN (0)
	END IF
'
	lastItem = item - 1
	REDIM name$[lastItem]
	IF (item > startSortItem) THEN							' sort by index
		XstQuickSort (@name$[], @null[],  startSortItem - 1, lastItem, $$SortIncreasing)
	END IF
	RETURN (item)
END FUNCTION
'
'
' #################################
' #####  TextHasNonWhites ()  #####
' #################################
'
FUNCTION  TextHasNonWhites (mode, (text$, text$[]))
	SHARED  UBYTE  charsetNonWhiteChar[]

	IF (mode = $$TextString) THEN
		IFZ text$ THEN RETURN (0)
		FOR i = 0 TO UBOUND(text$)
			cchar = text${i}
			IF charsetNonWhiteChar[cchar] THEN RETURN (cchar)
		NEXT i

	ELSE
		IFZ text$[] THEN RETURN (0)
		FOR line = 0 TO UBOUND(text$[])
			IFZ text$[line] THEN DO NEXT
			ATTACH text$[line] TO a$
			FOR i = 0 TO UBOUND(a$)
				cchar = a${i}
				IF charsetNonWhiteChar[cchar] THEN
					ATTACH a$ TO text$[line]
					RETURN (cchar)
				END IF
			NEXT i
			ATTACH a$ TO text$[line]
		NEXT line
	END IF
END FUNCTION
'
'
' #################################
' #####  TextToTokenArray ()  #####
' #################################
'
' TextToTokenArray (text$[], func[], funcNumber, freeze)
'   - Converts a source text array for an function into an irregular
'				array of tokens.
'   - "freeze" instructs compiler not to allow function renames.
'		- Removes trailing newlines and RTRIMs each line.
'   - If not PROLOG
'				- removes currentexe from func[]
'				- forces END FUNCTION to end of func[]
'   - If PROLOG
'				- removes BP/currentexe from func[]
'				- sets entryFunction:
'						- First function DECLAREd in PROLOG
'								(may or may not exist in code yet)
'						- Entry function cannot be INTERNAL or EXTERNAL
'
'	text$[] is returned MODIFIED to be identical with func[]
'
'	Return $$TRUE if bogus function rename was attempted
'
FUNCTION  TextToTokenArray (text$[], func[], funcNumber, freeze)
	EXTERNAL /xxx/  bogusFunction,  freezeFlag,  freezeFunction,  entryFunction
	EXTERNAL /xxx/  maxFuncNumber
	SHARED  UBYTE  charsetNonWhiteChar[]
	SHARED  prog[],  funcAltered[],  funcBPAltered[]
	SHARED  funcNeedsTokenizing[],  funcCursorPosition[]
	SHARED  uprog
	SHARED  T_DECLARE,  T_INTERNAL,  T_EXTERNAL
	SHARED  T_END,  T_FUNCTION,  T_CFUNCTION,  T_SFUNCTION
	SHARED  currentCursor
'
	IFZ text$[] THEN
		DIM func[]
		RETURN (freeze)										' empty and 'freeze' = 'renamed'
	END IF
'
	entryCursor = currentCursor
'	SetCursor ($$CursorWait)
'
	IF freeze THEN
		bogusFunction = $$FALSE						' Don't allow rename
		freezeFlag = $$TRUE
		freezeFunction = funcNumber
	ELSE
		freezeFlag = $$FALSE
	END IF
'
	IFZ funcNumber THEN
		entryFunction = 0
		XxxInitParse ()										' Reset got.function for PROLOG
	END IF
	nullText = $$TRUE
'
	uText = UBOUND(text$[])
	tLine = 0
	uLine = uText
	DIM func[uLine,]
	DIM newText$[uLine]
'
	FOR i = 0 TO uText
		SWAP text$[i], text$
		IF text$ THEN															' quick RTRIM non-printables
			IFZ charsetNonWhiteChar[text${UBOUND(text$)}] THEN
				j = UBOUND(text$)
				DO
					DEC j
					IF (j < 0) THEN EXIT DO
				LOOP UNTIL charsetNonWhiteChar[text${j}]
				IF (j < 0) THEN
					text$ = ""
				ELSE
					text${j + 1} = 0										' null terminates
					xAddr = &text$											' Ahem...
					XLONGAT (xAddr, -8) = j + 1
				END IF
			END IF
		END IF
'
		IFZ text$ THEN
			INC blankLines
			DO NEXT
		END IF
		nullText = $$FALSE
'
		DO UNTIL (blankLines = 0)
			XxxParseSourceLine ("\n", @blankTok[])
			IF (tLine > uLine) THEN
				uLine = (uLine + (uLine >> 1)) OR 7
				REDIM func[uLine,]
				REDIM newText$[uLine]
			END IF
			ATTACH blankTok[] TO func[tLine,]				' newText$[] already empty
			INC tLine
			DEC blankLines
		LOOP
'
		XxxParseSourceLine (text$, @tok[])
		IF (tLine > uLine) THEN
			uLine = uLine + (uLine >> 1)
			REDIM func[uLine,]
			REDIM newText$[uLine]
		END IF
'
		IFZ tok[] THEN PRINT "tok[] empty!" : GOTO NextLine
		startToken = tok[0]
'
		IFZ funcNumber THEN
			IF startToken{$$BP_EXE} THEN
				tok[0] = startToken{$$CLEAR_BP_EXE}			' BP/currentexe illegal in PROLOG
				XxxDeparser (@tok[], @text$)
				startToken = tok[0]
			END IF
		ELSE
			IF startToken{$$EXE} THEN
				tok[0] = startToken AND 0xBFFFFFFF			' waste currentexe (handled elsewhere)
				XxxDeparser (@tok[], @text$)
				startToken = tok[0]
			END IF
		END IF
		toks = startToken{$$BYTE0}
'
		IF (toks <= 1) THEN GOTO NextLine
		tokPtr = 1
		IFZ NextXitToken(@tok[], @tokPtr, toks, @token) THEN GOTO NextLine
		IFZ funcNumber THEN										' PROLOG:  set entryFunction
			IF entryFunction THEN GOTO NextLine
			IF ((token = T_DECLARE) OR (token = T_INTERNAL)) THEN
				IFZ NextXitToken(@tok[], @tokPtr, toks, @token) THEN GOTO NextLine
				SELECT CASE token
					CASE  T_FUNCTION, T_CFUNCTION, T_SFUNCTION
					CASE  ELSE:			GOTO NextLine
				END SELECT
				DO
					IFZ NextXitToken(@tok[], @tokPtr, toks, @token) THEN GOTO NextLine
					IF (token{$$KIND} = $$KIND_FUNCTIONS) THEN
						entryFunction = token{$$NUMBER}
						EXIT DO
					END IF
				LOOP
			END IF
		ELSE																	' Not PROLOG:  END FUNCTION?
			IF (token = T_END) THEN
				IF NextXitToken(@tok[], @tokPtr, toks, @token) THEN
					SELECT CASE token
						CASE  T_FUNCTION, T_CFUNCTION, T_SFUNCTION
							DIM endFunctionTok[]				' Save END FUNCTION for later
							ATTACH tok[] TO endFunctionTok[]
							DO NEXT
					END SELECT
				END IF
			END IF
		END IF
'
NextLine:
		ATTACH tok[] TO func[tLine,]
		ATTACH text$ TO newText$[tLine]
		INC tLine
	NEXT i
'
	IF (maxFuncNumber > uprog) THEN
		uprog = maxFuncNumber + (maxFuncNumber >> 2)
		REDIM prog[uprog,]
		REDIM funcAltered[uprog]
		REDIM funcBPAltered[uprog]
		REDIM funcNeedsTokenizing[uprog]
		REDIM funcCursorPosition[uprog, 5]
	END IF
'
	bogus = bogusFunction
	IF freeze THEN
		bogusFunction = $$FALSE
		freezeFlag = $$FALSE
		freezeFunction = 0
	END IF
'
	IF nullText THEN
		DIM func[]
		DIM text$[]
'		SetCursor (entryCursor)
		RETURN (bogus)
	END IF
'
	IF funcNumber THEN												' non-PROLOG needs END FUNCTION
		IF (tLine > uLine) THEN
			uLine = uLine + 1
			REDIM func[uLine,]
		END IF
		IFZ endFunctionTok[] THEN
			DIM endFunctionTok[3]									' last token must be null
			endFunctionTok[0] = $$T_STARTS + 3
			endFunctionTok[1] = T_END OR 0x20000000
			endFunctionTok[2] = T_FUNCTION
		END IF
		XxxDeparser (@endFunctionTok[], @text$)
		ATTACH endFunctionTok[] TO func[tLine,]
		ATTACH text$ TO newText$[tLine]
		IF (tLine < uLine) THEN
			REDIM func[tLine,]
			REDIM newText$[tLine]
		END IF
	ELSE
		IF ((tLine - 1) < uLine) THEN
			REDIM func[tLine-1,]
			REDIM newText$[tLine-1]
		END IF
	END IF
	SWAP newText$[], text$[]
'
'	SetCursor (entryCursor)
	RETURN (bogus)
END FUNCTION
'
'
' #################################
' #####  TokenArrayToText ()  #####
' #################################
'
'	Convert token array to text array
'		Does not remove blank lines
'		Does not test for excess END FUNCTIONS (done in TextToTokenArray())
'
FUNCTION  TokenArrayToText (funcNumber, text$[])
	SHARED  prog[]
	SHARED  programAltered,  exeFunction,  exeLine
	SHARED  currentCursor
'
	IFZ prog[funcNumber,] THEN
		DIM text$[]
		RETURN
	END IF
'
	entryCursor = currentCursor
'	SetCursor ($$CursorWait)
'
	ATTACH prog[funcNumber,] TO func[]
	uLine = UBOUND(func[])
	DIM text$[uLine]
	FOR line = 0 TO uLine
		ATTACH func[line,] TO tok[]
		IFZ tok[] THEN DO NEXT										' empty line
		IFZ funcNumber THEN
			tok[0] = tok[0]{$$CLEAR_BP_EXE}					' no breakpoints/currentexe in PROLOG
		ELSE
			tok[0] = tok[0] AND 0xBFFFFFFF
			IF (exeLine = line) THEN
				IF (exeFunction = funcNumber) THEN
					IF ##USERRUNNING THEN
						IFZ programAltered THEN
							tok[0] = tok[0] OR 0x40000000		' set currentexe
						END IF
					END IF
				END IF
			END IF
		END IF
		XxxDeparser(@tok[], @lineText$)
		ATTACH lineText$ TO text$[line]
		ATTACH tok[] TO func[line,]
	NEXT line
'
	ATTACH func[] TO prog[funcNumber,]
'	SetCursor (entryCursor)
END FUNCTION
'
'
' #####################################
' #####  UpdateFileFuncLabels ()  #####
' #####################################
'
FUNCTION  UpdateFileFuncLabels (updateFile, updateFunc)
	SHARED  editFilename$,  editFunction,  fileType,  textAlteredSinceLastSave
	SHARED  mainTitle$
	SHARED  xitGrid
'
	IF updateFile THEN
		part = RINSTR (editFilename$, $$PathSlash$)
		IF part THEN
			filename$ = MID$(editFilename$, part + 1)
		ELSE
			filename$ = editFilename$
		END IF
		IFZ filename$ THEN
			filename$ = "no_file_name"
		END IF
'
' the following code segment is inappropriate because the
' currently displayed function is already mentioned on the function drop button
'
		title$ = filename$ + " - " + mainTitle$
		XuiSetWindowTitle (xitGrid, #SetWindowTitle, 0, 0, 0, 0, 0, @title$)
'
		IF textAlteredSinceLastSave THEN
			lenName = LEN (filename$)
			filename$ = filename$ + " *"
		END IF
		XuiSendMessage (xitGrid, #GetTextString, 0, 0, 0, 0, $$xitFileLabel, @oldFilename$)
		IF (filename$ != oldFilename$) THEN
			XuiSendMessage (xitGrid, #SetTextString, 0, 0, 0, 0, $$xitFileLabel, @filename$)
			XuiSendMessage (xitGrid, #RedrawGrid, 0, 0, 0, 0, $$xitFileLabel, 0)
		END IF
	END IF
'
	IF updateFunc THEN
		IF (fileType = $$Text) THEN
			funcName$ = "text"
		ELSE
			XxxFunctionName ($$XGET, @funcName$, editFunction)
			IFZ funcName$ THEN
				funcName$ = "no_func_name"
			END IF
'			IF (LEN(funcName$) > 15) THEN
'				funcName$ = LEFT$(STUFF$(funcName$, "*", 15),15)
'			END IF
		END IF
		XuiSendMessage (xitGrid, #GetTextString, 0, 0, 0, 0, $$xitFunction, @oldFuncName$)
		IF (funcName$ != oldFuncName$) THEN
			XuiSendMessage (xitGrid, #SetTextString, 0, 0, 0, 0, $$xitFunction, @funcName$)
			XuiSendMessage (xitGrid, #Redraw, 0, 0, 0, 0, $$xitFunction, 0)
		END IF
	END IF
END FUNCTION
END PROGRAM
