' Syntax checker for XBLite/XBasic DEC files. Compile as an EXE to create a
'  command-line program, or as a DLL for use as an IMPORT module.
'
' Ken Minogue, 23 Mar 2004 
'
' As as EXE, usage is
'
'   checkdec decfile1 [decfile2 ...] [-a] [-t] [-o:filename]
'
' If more than one DEC file is listed on the command line, files are analyzed in
'  the order listed, and declarations in each file carry over to subsequent files. 
'  For example, a TYPE declared in decfile1 can be used in decfile2 without raising
'  an "Undeclared type" error; but if re-declared in decfile2 a "Duplicate
'  declaration" error will be reported.
'
' Optional switches:
'  -a
'    print all lines of the DEC file, interspersed with error messages if any.
'      Without this switch, only error messages are printed.
'
'  -t
'    print only a count of total errors.
'
'  -o:filename
'    print output to filename, instead of console.
'
'
' This program also illustrates the use of an exception handler to simplify error
'  reporting. Syntax errors are sent to Error(), which raises an exception, handled
'  by SUB Except in DecCheck(). Execution then continues at the SyntaxError label in
'  SUB CheckFiles. The advantage of this over traditional error-handling is that it 
'  does not matter where in the program the syntax error is detected - execution
'  control can go directly to SyntaxError without the need to back out of a long
'  series of nested SUB and function calls.
'
PROGRAM "checkdec"
VERSION "1.0"
CONSOLE

IMPORT "xst"
IMPORT "xsx"

'TYPE_STATUS is used to collect several status variables related to the
' syntax analysis of TYPE declarations; simplifies function calls.
TYPE TYPE_STATUS
	XLONG	.inType				'TRUE between TYPE and END TYPE statements
	XLONG	.inUnion			'TRUE between UNION and END UNION statements
	XLONG	.typeMembers	'number of members in the TYPE
	XLONG	.unionMembers	'number of members in the UNION
	XLONG	.colon				'TRUE if line contains multiple colon-separated statements
END TYPE

DECLARE  FUNCTION  CDEntry ()
EXPORT
DECLARE  FUNCTION  DecCheck (decfile$, keep, all, errorCount, maxErrorCount, callback)
END EXPORT
INTERNAL FUNCTION  PrintToFile (msg$)
INTERNAL FUNCTION  ParseConstant (@tokens$[], maxToken, TYPE_STATUS ts)
INTERNAL FUNCTION  ParseExternal (@tokens$[], maxToken)
INTERNAL FUNCTION  ParseType (@tokens$[], maxToken, TYPE_STATUS ts)
INTERNAL FUNCTION  ParseTypeMember (@tokens$[], maxToken, TYPE_STATUS ts)
INTERNAL FUNCTION  ParseEnd (@tokens$[], maxToken, TYPE_STATUS ts)
INTERNAL FUNCTION  ParseUnion (@tokens$[], maxToken, TYPE_STATUS ts)
INTERNAL FUNCTION  NameOK (name$, symbolKind, implicitType$)
INTERNAL FUNCTION  NameList (name$, symbolKind, mode)
INTERNAL FUNCTION  FuncAddrAlias (typeName$, mode)
INTERNAL FUNCTION  Error (exceptionCode, data$)
INTERNAL FUNCTION  IntegerOK (s$, lower, upper)
INTERNAL FUNCTION  PrintMessage (msg$)

'symbol kind (for NameOK(), NameList())
$$Type				= 0 'type or type member
$$Function		= 1 'function or function argument
$$Constant		= 2	'global constant

'modes (for NameList(), FuncAddrAlias()
$$SearchList	=  0
$$AddToList		= -1
$$InitList		= -2		

$$MAX_XLONG = 0x7FFFFFFF

' ########################
' #####  CDEntry ()  #####
' ########################
'
'
FUNCTION  CDEntry ()
	IF LIBRARY(0) THEN RETURN

	XstGetCommandLineArguments (@count, @args$[])
	IF count < 2 THEN
		GOSUB Help
		RETURN
	END IF

	file = 0
	maxError = -1
	all = $$FALSE
	callback = 0
	FOR arg = 1 TO count-1
		SELECT CASE args$[arg]{0}
			CASE '-', '/'  'optional switches
				SELECT CASE LCASE$(args$[arg])
					CASE "-a"	: all = $$TRUE 'print all lines of DEC, as well as errors
					CASE "-t"	: maxError = 0 'print total error count only
					CASE ELSE
						p = INSTR(args$[arg], ":")
						IF p THEN
							IF LCASE$(LEFT$(args$[arg], p-1)) == "-o" THEN 'print to file
								outfile$ = MID$(args$[arg], p+1)
								IF outfile$ THEN
									#outfile = OPEN(outfile$, $$WRNEW)
									IF #outfile > 0 THEN
										callback = &PrintToFile()
										EXIT SELECT
									END IF
								END IF
							END IF
						END IF
						GOSUB Help 'not a recognized switch
						RETURN
				END SELECT
			CASE ELSE 'dec file name
				IF file > UBOUND(decFiles$[]) THEN REDIM decFiles$[file+5]
				decFiles$[file] = args$[arg]
				INC file
		END SELECT
	NEXT arg

	IFZ file THEN
		PRINT "No DEC files listed in command line."
		RETURN
	END IF

'send each file to DecCheck()
	maxFile = file - 1
	keep = $$TRUE
	FOR file = 0 TO maxFile
		dec$ = decFiles$[file]
		PRINT "Checking "; dec$
		IF DecCheck (@dec$, keep, all, @errorCount, maxError, callback) THEN
			PRINT "  Error loading "; decFiles$[file]
			DO NEXT
		END IF
		PRINT "Error count for " + dec$ + " ="; errorCount
		totalErrors = totalErrors + errorCount
		PRINT
	NEXT file

	IF maxFile > 0 THEN PRINT "Total error count ="; totalErrors
	IF #outfile > 0 THEN CLOSE(#outfile)
	RETURN

SUB Help
	PRINT "Syntax checker for DEC files."
	PRINT
	PRINT	"    checkdec decfile [decfile ...] [-a] [-t] [-o:outfile]"
	PRINT
	PRINT "  optional switches:"
	PRINT "    -a  output all lines in the DEC file, in addition to errors"
	PRINT "    -t  report only total count of errors"
	PRINT "    -o:outfile send output to the specified file"
	PRINT
	PRINT "  More than one DEC file can be listed on the command line."
	PRINT "  Files will be checked in the order listed, and declarations"
	PRINT "  carried over from one file to the next."
END SUB
END FUNCTION
'
' ############################
' #####  PrintToFile ()  #####
' ############################
'
' Send output to file, if -o switch is used on command line
'
FUNCTION  PrintToFile (msg$)
	PRINT [#outfile], msg$
END FUNCTION
'
' #########################
' #####  DecCheck ()  #####
' #########################
'
' decfile$ is the name of a DEC file to be checked for syntax errors. If there is
'  no extension, .dec is assumed. If the name contains no path, the file will be
'  searched for in the current folder, the XBlite include folder, and the XBasic
'  include folder, in that order. In order to find the include folders, one or
'  both of the environment variables XBLDIR and XBDIR must be set.
'
' keep is TRUE to keep types, constants and functions declared in the previously
'  analyzed file(s), if any. Otherwise these declarations are cleared, and the
'  analysis starts fresh with the current file.
'
' all is TRUE to send all lines of the DEC file to the callback function, in
'   addition to syntax errors. If FALSE, only errors are reported.

' maxErrorCount is the maximum number of errors to report; syntax checking
'  continues when this count is exceeded, but only the total error count is reported.
'  If maxErrorCount < 0, all errors are reported.  If 0, no errors are reported, 
'  only the total error count.
'
' callback is the address of a callback function to receive error. If 0, messages
'  are printed to the console. The callback function must have one STRING argument.
'  The function should return 0 to continue processing of the DEC file, non-zero
'  to cancel.
'
' return value is TRUE if decfile$ cannot be loaded, otherwise FALSE.
'
FUNCTION DecCheck (decfile$, keep, all, errorCount, maxErrorCount, callback)
	EXCEPTION_DATA exception
	FUNCADDR Report (STRING)
	TYPE_STATUS ts, ts_null
	STATIC delimiter[]
	STATIC checked$[]

	Report = callback
	IFZ Report THEN Report = &PrintMessage()

	IFZ delimiter[] THEN GOSUB Init

	errorCount = 0
	IF maxErrorCount < 0 THEN maxErrors = $$MAX_XLONG ELSE maxErrors = maxErrorCount

	IFZ decfile$ THEN RETURN

'try to open decfile in current folder, XBlite include, or XBasic include
	XstDecomposePathname (@decfile$, @path$, "", "", "", @ext$)
	IFZ ext$ THEN decfile$ = decfile$ + ".dec"
	fullname$ = decfile$
	IF path$ THEN
			IF XstLoadStringArray (@decfile$, @dec$[]) THEN
				RETURN $$TRUE
			END IF
		ELSE
			IF XstLoadStringArray (@decfile$, @dec$[]) THEN
				fullname$ = XstPathString$ ("$XBLDIR\\include\\" + decfile$)
				IF XstLoadStringArray (@fullname$, @dec$[]) THEN
					fullname$ = XstPathString$ ("$XBDIR\\include\\" + decfile$)
					IF XstLoadStringArray (@fullname$, @dec$[]) THEN
						RETURN $$TRUE
					END IF
				END IF
			END IF
	END IF
	decfile$ = fullname$ 'tells calling function full name of file
	IFZ dec$[] THEN RETURN 'no contents

'maintain list of files checked, in case same file appears more than once
	IFF keep THEN DIM checked$[]
	ub = UBOUND(checked$[])
	FOR file = 0 TO ub
		IF checked$[file] == decfile$ THEN RETURN 'already checked this file
	NEXT file
	INC ub
	REDIM checked$[ub]
	checked$[ub] = decfile$

'clear lists of declared TYPEs, constants, and functions
	IFF keep THEN
		NameList ("", 0, $$InitList)
		FuncAddrAlias ("", $$InitList)
	END IF

'Set up exception handler to deal with syntax errors, and call SUB CheckFile
	XstTry (SUBADDRESS(CheckFile), SUBADDRESS(Except), @exception)
	RETURN

'this SUB is the main loop for syntax checking
SUB CheckFile
	ts = ts_null
	DO UNTIL (more$ == "") & (line > UBOUND(dec$[]))
		GOSUB GetLine 'get a logical line from the DEC file
		IFZ line$ THEN DO LOOP
		GOSUB Tokenize 'break line into individual units
		SELECT CASE tokens$[0] 'analyze according to first token in line
			CASE "IMPORT"
				file$ = tokens$[2] + ".dec"
				DecCheck (@file$, -1, 0, @errors, 0, callback)
			CASE "TYPE", "PACKED"	: ParseType(@tokens$[], maxToken, @ts)
			CASE "EXTERNAL"				: ParseExternal(@tokens$[], maxToken)
			CASE "END"						:	ParseEnd(@tokens$[], maxToken, @ts)
			CASE "UNION"					: ParseUnion(@tokens$[], maxToken, @ts)
			CASE ELSE
				IF ts.inType THEN
															ParseTypeMember(@tokens$[], maxToken, @ts)
						ELSE
															ParseConstant(@tokens$[], maxToken, @ts)
				END IF
		END SELECT
SyntaxError: 'common return point for all syntax errors
	LOOP
END SUB

'exception handler, called when a syntax error is detected
SUB Except

'if not a CheckDec exception, pass it on to the next exception handler
	IF (exception.code < #First) OR (exception.code > #Last) THEN
		exception.response = $$ExceptionForward
		EXIT SUB
	END IF

'#Cancel exception is raised only if callback (Report) function has
' returned non-zero after outputting a line from the DEC file (see SUB GetLine)
	IF exception.code == #Cancel THEN 'return from XstTry()
		exception.response = $$ExceptionTerminate
		EXIT SUB
	END IF

'report error to callback function
	INC errorCount
	IF errorCount <= maxErrors THEN
		XstExceptionNumberToName (exception.code, @ex$)
		message$ = "At line " + STR$(line) + " >> " + ex$
		IF exception.info[0] THEN 'pointer to additional data about error
			message$ = message$ + ": " + CSTRING$(exception.info[0])
		END IF
		cancel = @Report (@message$)
		IFF all THEN @Report ("  " + dec$[line-1])
	END IF
	
	IF cancel THEN
			exception.response = $$ExceptionTerminate
		ELSE
			exception.response = $$ExceptionRetry
			exception.address = GOADDRESS(SyntaxError)
	END IF
END SUB
'
' ************************
' ***** SUB GetLine  *****
' ************************
'
' - retrieves the next logical line from the DEC file (a single physical line
'    may have more that one logical line, separated by colons).
' - removes comments from the line.
' - trims whitespace from the ends of the line.
'
' Most of the code in this SUB is concerned with distinguishing a single-quote
'  that begins a comment from single-quotes that may occur in other contexts.
'
SUB GetLine
	IF more$ THEN
			line$ = more$
			more$ = ""
			ts.colon = $$TRUE 'this logical line continues same physical line
		ELSE
			line$ = TRIM$(dec$[line])
			IF all THEN
				IF @Report(@line$) THEN Error(#Cancel, "")
			END IF
			INC line
			ts.colon = $$FALSE
	END IF
	escape = $$FALSE
	inQuote = $$FALSE
	inByte = $$FALSE
	gotEquals = $$FALSE
	FOR p = 0 TO LEN(line$)-1
		SELECT CASE line${p}
			CASE '\\'
				IF inQuote THEN escape = !escape
				gotEquals = $$FALSE
			CASE '\"'
				IFF escape THEN inQuote = !inQuote
				gotEquals = $$FALSE
			CASE '='
				gotEquals = !inQuote
			CASE '''
				SELECT CASE TRUE
					CASE gotEquals 'byte assignment (eg. $$DASH = '-')
						inByte = $$TRUE
						gotEquals = $$FALSE
					CASE inByte
						inByte = $$FALSE
					CASE inQuote
					CASE ELSE 'trim off comment and proceed
						IFZ p THEN
								line$ = TRIM$(MID$(line$,2))
								IF LEFT$(line$, 6) != "IMPORT" THEN line$ = ""
							ELSE
								line$ = TRIM$(LEFT$(line$,p))
						END IF
						EXIT FOR
				END SELECT
			CASE ':'
				IFF inQuote|inByte THEN
					more$ = TRIM$(MID$(line$,p+2))
					line$ = TRIM$(LEFT$(line$,p))
					EXIT FOR
				END IF
			CASE ' ', '\t'
				escape = $$FALSE
			CASE ELSE
				escape = $$FALSE
				gotEquals = $$FALSE
		END SELECT
	NEXT p
END SUB
'
' **************************
' *****  SUB Tokenize  *****
' **************************
'
' Breaks the line into individual elements (tokens).
'
SUB Tokenize
'buffer to accumulate characters for each token
	tokenBuffer$ = NULL$(256)

	maxToken = 0 'index for tokens$[]
	linePtr = 0  'pointer into line$
	tokenPtr = 0 'pointer into tokenBuffer$ 
	constant = (line${0} == '$') 'indicates line presumably declares a constant
	#value$ = "" 'holds value of constant
	DIM tokens$[100]    'tokens for each line

	DO WHILE linePtr <= LEN(line$) 'use terminating null to exit loop
		Char = line${linePtr}
		IFF delimiter[Char] THEN 'accumulate characters in buffer
				tokenBuffer${tokenPtr} = Char
				INC tokenPtr
			ELSE 'found delimiter, so get current buffer contents and look for next token
				IF tokenPtr THEN
					tokens$[maxToken] = LEFT$(tokenBuffer$, tokenPtr)
					INC maxToken
					tokenPtr = 0
				END IF
				SELECT CASE Char
					CASE ' ', '\t'
						DO WHILE linePtr < LEN(line$) 'skip extra whitespace
							SELECT CASE line${linePtr}
								CASE ' ','\t' : INC linePtr
								CASE ELSE			:	DO LOOP 2
							END SELECT
						LOOP
					CASE '.' 'possible ellipsis (...) in CFUNCTION
						DO WHILE line${linePtr+1} == '.'
							tokenBuffer${tokenPtr} = '.'
							INC linePtr
							INC tokenPtr
						LOOP
						IFZ tokenPtr THEN NEXT CASE 'not ellipsis, fall through to CASE ELSE
						tokenBuffer${tokenPtr} = '.'
						tokens$[maxToken] = LEFT$(tokenBuffer$, tokenPtr+1)
						INC maxToken
						tokenPtr = 0
					CASE 0		: EXIT DO 'terminating null at end of line$
					CASE ELSE
						tokens$[maxToken] = CHR$(Char)
						INC maxToken
				END SELECT
				IF constant & (maxToken == 2) THEN
					#value$ = TRIM$(MID$(line$,linePtr+2))
				END IF
		END IF
		INC linePtr
	LOOP
	DEC maxToken
END SUB

SUB Init
'characters recognized as token delimiters
	DIM delimiter[255]
	FOR i = 0 TO 255
		delimiter[i] = $$TRUE
	NEXT i
	FOR i = 'A' TO 'Z'
		delimiter[i] = $$FALSE
	NEXT i
	FOR i = 'a' TO 'z'
		delimiter[i] = $$FALSE
	NEXT i
	FOR i = '0' TO '9'
		delimiter[i] = $$FALSE
	NEXT i
	delimiter['_'] = $$FALSE
	delimiter['@'] = $$FALSE
	delimiter['%'] = $$FALSE
	delimiter['&'] = $$FALSE
	delimiter['~'] = $$FALSE
	delimiter['$'] = $$FALSE
	delimiter['!'] = $$FALSE
	delimiter['#'] = $$FALSE

'register exceptions for error messages
	XstRegisterException (@"CheckDec First",								@#First)

	XstRegisterException (@"Syntax error",									@#Syntax)
	XstRegisterException (@"Duplicate declaration",					@#Duplicate)
	XstRegisterException (@"Extra characters in line",			@#ExtraCharacters)
	XstRegisterException (@"Out of place",									@#OutOfPlace)
	XstRegisterException (@"Syntax checking cancelled",			@#Cancel)

	XstRegisterException (@"Error in constant declaration",	@#Constant)
	XstRegisterException (@"Invalid constant name",					@#ConstantName)
	XstRegisterException (@"Undeclared constant",						@#UndeclaredConstant)
	XstRegisterException (@"Error in literal string",				@#StringError)
	XstRegisterException (@"Error in literal byte",					@#ByteError)
	XstRegisterException (@"Error in literal numeric",			@#NumericError)
	XstRegisterException (@"Error in BITFIELD",							@#BitfieldError)

	XstRegisterException (@"Error in type declaration",			@#Type)
	XstRegisterException (@"Invalid type name",							@#TypeName)
	XstRegisterException (@"Undeclared type",								@#UndeclaredType)
	XstRegisterException (@"Nesting error",									@#NestingError)
	XstRegisterException (@"Error in type member",					@#TypeMember)
	XstRegisterException (@"Type has no members",						@#NoTypeMembers)
	XstRegisterException (@"UNION has no members",					@#NoUnionMembers)
	XstRegisterException (@"Missing END UNION",							@#NoEndUnion)
	XstRegisterException (@"Missing END TYPE",							@#NoEndType) 'not used
	XstRegisterException (@"Colon in type declaration",			@#ColonError)
	XstRegisterException (@"Array needs dimension",					@#NoDimension)
	XstRegisterException (@"Invalid array dimension",				@#BadDimension)
	XstRegisterException (@"Illegal FUNCADDR or alias",			@#FuncAddr)

	XstRegisterException (@"Error in function declaration",	@#Function)
	XstRegisterException (@"Invalid function name",					@#FunctionName)
	XstRegisterException (@"Error in arguments",						@#ArgumentError)
	XstRegisterException (@"Missing argument",							@#MissingArgument)
	XstRegisterException (@"Type mismatch",									@#TypeMismatch)

	XstRegisterException (@"CheckDec Last",									@#Last)

END SUB
END FUNCTION
'
' ##############################
' #####  ParseConstant ()  #####
' ##############################
'
'$$CONST = numeric, string, byte, BITFIELD, or another constant
'
FUNCTION  ParseConstant (tokens$[], maxToken, TYPE_STATUS ts)

	IF maxToken < 2 THEN Error (#Syntax, "")
	IF ts.inType THEN Error (#OutOfPlace, "")

'constant name properly formed?
	name$ = tokens$[0]
	IF name${0} != '$' THEN Error (#Syntax, "") 'not a constant?
	IFF NameOK (@name$, $$Constant, @implicitType$) THEN Error (#ConstantName, @name$)
	IF implicitType$ THEN 'only $ suffix is allowed for constant names
		IF implicitType$ != "STRING" THEN Error (#ConstantName, @name$)
	END IF
'add to list of declared constants - error if already declared
	IFF NameList (@name$, $$Constant, $$AddToList) THEN Error (#Duplicate, @name$)

'equals sign?
	IF tokens$[1] != "=" THEN Error (#Constant, "")

'is there a value available for the constant?
	IFZ #value$ THEN Error (#Constant, "")

'token following "="
	token$ = tokens$[2]
	IF token$ == "BITFIELD" THEN
			GOSUB BitfieldAssign
		ELSE
			SELECT CASE token${0}
				CASE '$'	: GOSUB ConstantAssign
				CASE '\"'	: GOSUB StringAssign
				CASE '''	: GOSUB ByteAssign
				CASE '-'	: GOSUB Negation
				CASE ELSE	: GOSUB NumericAssign
			END SELECT
	END IF
	RETURN

'value begins with "-", could be -$$CONST or -numeric
SUB Negation
	v$ = TRIM$(LCLIP$(#value$))
	IFZ v$ THEN Error (#Constant, @"-")
	IF v${0} == '$' THEN
			#value$ = v$
			GOSUB ConstantAssign
		ELSE
			GOSUB NumericAssign
	END IF
END SUB

'$$CONST = numeric
SUB NumericAssign
	IF implicitType$ == "STRING" THEN Error (#TypeMismatch, "")

 'XstStringToNumber() fails if whitespace follows a + or -
	SELECT CASE #value${0}
		CASE '+'	: #value$ = "+" + TRIM$(LCLIP$(#value$))
		CASE '-'	: #value$ = "-" + TRIM$(LCLIP$(#value$))
	END SELECT

	ret = XstStringToNumber (@#value$, 0, @end, @rtype, @value$$)
	IF (ret == -1) THEN Error (#NumericError, @#value$)

	IF (end < LEN(#value$)) THEN 'extra characters, might be a type suffix
		suffix$ = MID$(#value$, end+1)
		SELECT CASE suffix$
			CASE "@", "@@", "%", "%%", "&", "&&", "~"
				SELECT CASE rtype
					CASE $$SINGLE, $$DOUBLE, $$GIANT
						Error (#TypeMismatch, @#value$)
				END SELECT
			CASE "$$", "!", "#"
			CASE ELSE 'not a suffix, thus error
				Error (#ExtraCharacters, "")
		END SELECT
	END IF
END SUB

'$$CONST1 = $$CONST2
SUB ConstantAssign
	p = INCHR(#value$, " \t") 'p > 0 only if extra characters on line
	IF p THEN #value$ = LEFT$(#value$,p-1)

'is $$CONST2 a valid name?
	IFF NameOK (@#value$, $$Constant, "") THEN
		Error (#ConstantName, @#value$)
	END IF

'has $$CONST2 been declared?
	IFF NameList (@#value$, $$Constant, $$SearchList) THEN
		Error (#UndeclaredConstant, @#value$)
	END IF

	IF p THEN Error(#ExtraCharacters, "")
END SUB

'$$CONST = "string"
SUB StringAssign
'check syntax of string being assigned to a constant
	pmax = LEN(#value$)-1
	escape = $$FALSE
	FOR p = 1 TO pmax
		SELECT CASE #value${p}
			CASE '\\'
				escape = !escape
			CASE '\"'
				IFF escape THEN EXIT FOR 'found end quote
				escape = $$FALSE
			CASE ELSE
				escape = $$FALSE
		END SELECT
	NEXT p
	IF p > pmax THEN Error (#StringError, @#value$)  'did not find end quote
	IF p < pmax THEN Error (#ExtraCharacters, "")
END SUB

'$$CONST = 'n' or $$CONST = '\n'
SUB ByteAssign
	IFZ #value$ THEN Error (#Constant, "")

	pmax = LEN(#value$) - 1
	SELECT CASE pmax
		CASE 0, 1
			OK = $$FALSE
		CASE 2
			OK = (#value${2} == ''')
		CASE ELSE	
			IF (#value${1} == '\\') THEN OK = (#value${3} == ''')
			IF OK & (pmax > 3) THEN Error (#ExtraCharacters, "")
	END SELECT

	IFF OK THEN Error (#ByteError, @#value$)
END SUB

'$$CONST = BITFIELD(width,offset)
' width and offset must be integers or declared constants in the range 0 - 31 
SUB BitfieldAssign
	IF maxToken < 7 THEN Error (#BitfieldError, "")

	error$ = ""
	IF tokens$[3] == "(" THEN
		width$ = tokens$[4]
		IF IntegerOK (@width$, 0, 31) THEN
				IF tokens$[5] == "," THEN
					offset$ = tokens$[6]
					IF IntegerOK (@offset$, 0, 31) THEN
							IF tokens$[7] == ")" THEN
								IF maxToken > 7 THEN Error (#ExtraCharacters, "")
								EXIT SUB 'no syntax errors detected
							END IF
						ELSE
							error$ = "invalid offset"
					END IF
				END IF
			ELSE
				error$ = "invalid width"
		END IF
	END IF

	Error (#BitfieldError, @error$)
END SUB

END FUNCTION
'
' ##############################
' #####  ParseExternal ()  #####
' ##############################
'
' EXTERNAL FUNCTION ReturnType FuncName (argType argName,...)
'
FUNCTION  ParseExternal (tokens$[], maxToken)
	IF maxToken < 4 THEN Error (#Function, "")

	SELECT CASE tokens$[1]
		CASE "FUNCTION", "CFUNCTION", "SFUNCTION"
		CASE ELSE	: Error (#Syntax, "")
	END SELECT

'get function name, and explicit return type, if any
	SELECT CASE TRUE
		CASE tokens$[3] == "("
			returnType$ = ""
			funcName$ = tokens$[2]
			nextToken = 4
		CASE tokens$[4] == "("
			returnType$ = tokens$[2]
			funcName$ = tokens$[3]
			nextToken = 5
		CASE ELSE
			Error (#Function, "")
	END SELECT

'check syntax of function name
	IFF NameOK (@funcName$, $$Function, @implicitType$) THEN
		Error (#FunctionName, @funcName$)
	END IF

'add name to function name list; error if already there
	IFF NameList	(@funcName$, $$Function, $$AddToList) THEN
		Error (#Duplicate, @funcName$)
	END IF

'if there is an explicit return type, check syntax,
	IF returnType$ THEN
		IFF NameOK (@returnType$, $$Type, "") THEN Error (#TypeName, @returnType$)
	'do not allow FUNCADDR or equivalent as a return type,
		IF FuncAddrAlias (returnType$, $$SearchList) THEN	Error (#FuncAddr, @returnType$)
	'make sure type has been declared,
		IFF NameList (@returnType$, $$Type, $$SearchList) THEN
			Error (#UndeclaredType, @returnType$)
		END IF
	'and compare to implicit type (from suffix of function name, if any).
		IF implicitType$ THEN
			IF returnType$ != implicitType$ THEN
				data$ = returnType$ + "/" + implicitType$
				Error (#TypeMismatch, @data$)
			END IF
		END IF
	END IF

'function name and return type look OK, so check arguments
	argName$ = ""
	argType$ = ""
	gotComma = $$FALSE
	arrayArg = $$FALSE
	byRef = $$FALSE
	DO WHILE nextToken <= maxToken
		token$ = tokens$[nextToken]
		INC nextToken
		byRef = (token${0} == '@')
		IF byRef THEN token$ = LCLIP$(token$)
		SELECT CASE TRUE
			CASE (token$ == ",") 'argument separator
				IF (argName$ == "")&(argType$ == "" ) THEN Error (#MissingArgument, "")
				argName$ = "": argType$ = ""
				arrayArg = $$FALSE
				gotComma = $$TRUE
			CASE (token$ == ")") 'end of argument list
				IF (argName$ == "") & (argType$ == "" ) THEN
					IF gotComma THEN Error (#MissingArgument, "")
				END IF
				EXIT DO
			CASE (token$ == "...") 'allowed only as last argument of CFUNCTION
				IF tokens$[1] == "CFUNCTION" THEN
					IF tokens$[nextToken] == ")" THEN INC nextToken: EXIT DO
				END IF
				Error (#ArgumentError, @token$)
			CASE (token$ == "[") 'array argument, closing ] must follow immediately
				IF tokens$[nextToken] != "]" THEN
					data$ = argName$
					IFZ data$ THEN data$ = argType$
					IFZ data$ THEN data$ = token$
					Error (#ArgumentError, @data$)
				END IF
				IF (argName$ == "")&(argType$ == "" ) THEN
					Error (#ArgumentError, @"[]")
				END IF
				arrayArg = $$TRUE
				INC nextToken
			CASE NameList (@token$, $$Type, $$SearchList) 'is token a declared TYPE?
				IF argType$ THEN Error (#ArgumentError, @token$) 'already have TYPE 
				IF byRef THEN Error (#ArgumentError, "@"+token$)'@TYPENAME not allowed
				argType$ = token$
				IF FuncAddrAlias (@argType$, $$SearchList) THEN Error (#FuncAddr, @argType$)
			CASE NameOK (@token$, $$Function, @implicitType$) 'argument name?
				IF argType$ THEN 'make sure explicit TYPE matches name suffix, if any
					IF implicitType$ THEN
						IF implicitType$ != argType$ THEN
							data$ = argType$ + "/" + implicitType$
							Error (#TypeMismatch, @data$)
						END IF
					END IF
				'we have argType, thus current token must be argName; but
				' if brackets follow argType, no argName is allowed
					IF arrayArg THEN Error (#ArgumentError, @token$)
				END IF
				IF argName$ THEN 'already have a name
				'probably mistook undeclared argument type for a name
					IF argType$ THEN error = #ArgumentError ELSE error = #UndeclaredType
					Error (error, @argName$)
				END IF
				argName$ = token$ 'accept this as the argument name
			CASE ELSE	: Error (#ArgumentError, @token$) 'don't know what's going on
		END SELECT
	LOOP

	SELECT CASE TRUE
		CASE (nextToken <= maxToken): Error (#ExtraCharacters, "")
		CASE (nextToken > maxToken+1): Error (#ArgumentError, "")
	END SELECT
END FUNCTION
'
' ##########################
' #####  ParseType ()  #####
' ##########################
'
'TYPE equivalence,  "TYPE newType = oldType"
'or beginning of composite type, "TYPE newType"
'
FUNCTION  ParseType (tokens$[], maxToken, TYPE_STATUS ts)

'if already within a TYPE block, there's a problem
	IF ts.inType THEN Error (#NestingError, "")
	IFZ maxToken THEN Error (#Syntax, "")

'cannot use line-separator colon within a TYPE
	IF ts.colon THEN Error (#ColonError, "")

	IF (tokens$[2] != "=") THEN
		ts.inType = $$TRUE 'presumably starting a TYPE block
	'clear list of members and zero member counts
		DIM memberNames$[100]
		ts.typeMembers = 0
		ts.unionMembers = 0
	END IF

'does type name follow valid syntax?
	typeName$ = tokens$[1]
	IFF NameOK (@typeName$, $$Type, "") THEN Error (#TypeName, @typeName$)

'add type name to list ; error if name has already been used
	IFF NameList (@typeName$, $$Type, $$AddToList) THEN Error (#Duplicate, @typeName$)

	IFF ts.inType THEN 'single-line NewTYPE = OldTYPE
		'old type name must be previously declared
			oldType$ = tokens$[3]
			IFZ oldType$ THEN Error (#Type, "")
			IF FuncAddrAlias (@oldType$, $$SearchList) THEN 'if old type is equivalent to FUNCADDR,
					FuncAddrAlias (@typeName$, $$AddToList) 'then so is new type
				ELSE
					IFF NameList (@oldType$, $$Type, $$SearchList) THEN
						Error (#UndeclaredType, @oldType$)
					END IF
			END IF
			IF maxToken > 3 THEN Error (#ExtraCharacters, "")
		ELSE  'multi-line TYPE block
			IF maxToken > 1 THEN Error (#ExtraCharacters, "")
	END IF
END FUNCTION
'
' ################################
' #####  ParseTypeMember ()  #####
' ################################
'
'inside a composite TYPE block, looking for members
'
FUNCTION  ParseTypeMember (tokens$[], maxToken, TYPE_STATUS ts)

	INC ts.typeMembers 'count of members in this TYPE
	IF ts.inUnion THEN INC ts.unionMembers 'inside a UNION block

'the : line continuation character causes problems inside a TYPE block
	IF ts.colon THEN Error (#ColonError, "")

'does member type name follow valid syntax?
	memberType$ = tokens$[0]
	IFF NameOK (@memberType$, $$Type, "") THEN Error (#TypeName, @memberType$)

'is member type built-in or previously declared
	funcaddr =  FuncAddrAlias (@memberType$, $$SearchList)
	IFF funcaddr THEN 'types equivalent to FUNCADDR are dealt with later
		IFF NameList (@memberType$, $$Type, $$SearchList) THEN
			Error (#UndeclaredType, @memberType$)
		END IF
	END IF

	IF maxToken < 2 THEN Error(#TypeMember, "")

'STRING types need to be followed by *integer or *constantName
	nextToken = 1
	IF memberType$ == "STRING" THEN
		IF tokens$[nextToken] != "*" THEN Error (#Syntax, tokens$[1])
		INC nextToken
		len$ = tokens$[nextToken]
		IFF IntegerOK (@len$, 1, $$MAX_XLONG) THEN Error (#Syntax, @len$)
		INC nextToken
	END IF

'member name needs dot
	IF tokens$[nextToken] != "." THEN Error (#TypeMember, @"missing .")
	INC nextToken

	memberName$ = tokens$[nextToken]
	IFF NameOK (@memberName$, $$Type, "") THEN Error (#TypeMember, @memberName$)
'add member name to list for this TYPE; error if already there
	FOR i = 0 TO UBOUND(memberNames$[])
		IFZ memberNames$[i] THEN EXIT FOR
		IF memberName$ == memberNames$[i] THEN Error (#Duplicate, @memberName$)
	NEXT i
	IF i > UBOUND(memberNames$[]) THEN REDIM memberNames$[i + 50]
	memberNames$[i] = memberName$
	INC nextToken

'if array member, check syntax
	IF tokens$[nextToken] == "[" THEN
		INC nextToken
		token$ = tokens$[nextToken]
		IF token$ == "]" THEN Error (#NoDimension, "")
		IFF IntegerOK (@token$, 0, $$MAX_XLONG) THEN Error (#BadDimension, @token$)
		INC nextToken
		IF tokens$[nextToken] != "]" THEN Error (#Syntax, @"missing ]")
		INC nextToken
	END IF

'FUNCADDR (or alias) needs (), optionally with one or more comma-separated TYPEs
	IF funcaddr THEN
		IF tokens$[nextToken] != "(" THEN Error (#ArgumentError, "")
		INC nextToken
		IF tokens$[nextToken] == ")" THEN EXIT IF 2 'no arguments
		DO WHILE nextToken <= maxToken
			argType$ = tokens$[nextToken]
			IF FuncAddrAlias (@argType$, $$SearchList) THEN Error (#FuncAddr, @argType$)
			IFF NameList(@argType$, $$Type, $$SearchList) THEN Error (#UndeclaredType, @argType$)
			INC nextToken
			SELECT CASE tokens$[nextToken]
				CASE ","
				CASE ")"	: EXIT DO
				CASE ELSE	: Error (#ArgumentError, "")
			END SELECT
			INC nextToken
		LOOP
	ELSE
		DEC nextToken
	END IF

	IF nextToken > maxToken THEN Error (#Syntax, "")
	IF nextToken < maxToken THEN Error (#ExtraCharacters, "")
END FUNCTION
'
' #########################
' #####  ParseEnd ()  #####
' #########################
'
' END TYPE or END UNION
'
FUNCTION  ParseEnd (tokens$[], maxToken, TYPE_STATUS ts)

	SELECT CASE tokens$[1]
		CASE "TYPE"
			IFF ts.inType THEN Error (#OutOfPlace, @"END TYPE") 'not in a TYPE block
			ts.inType = $$FALSE
			IF ts.colon THEN Error (#ColonError, "")
			IFZ ts.typeMembers THEN Error (#NoTypeMembers, "") 'type has no members
			IF ts.inUnion THEN 'missing an END UNION statement
				ts.inUnion = $$FALSE
				Error (#NoEndUnion, "")
			END IF
		CASE "UNION"
			IFF ts.inUnion THEN Error (#OutOfPlace, @"END UNION") 'not in a UNION block
			ts.inUnion = $$FALSE
			IF ts.colon THEN Error (#ColonError, "")
			IFZ ts.unionMembers THEN Error (#NoUnionMembers, "") 'UNION has no members
		CASE ELSE
			Error (#Syntax, "")
	END SELECT

	IF maxToken > 1 THEN Error (#ExtraCharacters, "")
END FUNCTION
'
' ###########################
' #####  ParseUnion ()  #####
' ###########################
'
'UNION
'
FUNCTION  ParseUnion (tokens$[], maxToken, TYPE_STATUS ts)

	IF ts.colon THEN Error (#ColonError, "")
	IF (ts.inType && !ts.inUnion) THEN
			ts.inUnion = $$TRUE
			ts.unionMembers = 0
		ELSE
			Error (#NestingError, "")
	END IF
	IF maxToken > 0 THEN Error (#ExtraCharacters, "")
END FUNCTION
'
' #######################
' #####  NameOK ()  #####
' #######################
'
'check name of type, type member, function, function argument, or constant for
' syntax, return $$TRUE if valid. Also return implicit type, if specified by suffix.
'
FUNCTION  NameOK (name$, symbolKind, implicitType$)
	STATIC UBYTE nameChar[]
'character kind
	$Alpha					= 0x01
	$Numeric				= 0x02
	$Underscore			= 0x04
	$Alpha_					= 0x05
	$AlphaNumeric_	= 0x07
	$Type1					= 0x08 '1st character of type suffix 
	$Type2					= 0x10 '2nd character of type suffix

	IFZ nameChar[] THEN GOSUB Init

	implicitType$ = ""
	IFZ name$ THEN RETURN
	pnmax = LEN(name$) - 1

	OK = $$FALSE
	SELECT CASE symbolKind
		CASE $$Type			: GOSUB TypeName			'type or type member
		CASE $$Function	: GOSUB FunctionName	'function or argument
		CASE $$Constant	: GOSUB ConstantName	'global constant
	END SELECT
	RETURN OK

'name of TYPE or member:
'  first - any alpha character
'  subsequent - any alpha-numeric character, or underscore
'  type suffix not allowed
SUB TypeName
	IFF (nameChar[name${0}] & $Alpha) THEN EXIT SUB 'invalid first character
	FOR p = 1 TO pnmax
		IFF (nameChar[name${p}] & $AlphaNumeric_) THEN EXIT SUB 'invalid char after first
	NEXT p
	OK = $$TRUE
END SUB

'name of function or function argument:
'  first - any alpha character, or underscore
'  subsequent - any alpha-numeric character, or underscore
'  one or two character type suffix is allowed
SUB FunctionName
	IF (nameChar[name${pnmax}] & $Type1) THEN 'type suffix
		IFZ pnmax THEN EXIT SUB 'no name, only suffix!
		IF nameChar[name${pnmax-1}] & $Type2 THEN '2-character type suffix
			IF name${pnmax} != name${pnmax-1} THEN EXIT SUB 'suffix characters don't match
			SELECT CASE name${pnmax}
				CASE '@'	: implicitType$ = "UBYTE"
				CASE '%'	: implicitType$ = "USHORT"
				CASE '&'	: implicitType$ = "ULONG"
				CASE '$'	: implicitType$ = "GIANT"
			END SELECT
			pnmax = pnmax - 2
		ELSE '1-character type suffix
			SELECT CASE name${pnmax}
				CASE '@'	: implicitType$ = "SBYTE"
				CASE '%'	: implicitType$ = "SSHORT"
				CASE '&'	: implicitType$ = "SLONG"
				CASE '~'	: implicitType$ = "XLONG"
				CASE '$'	: implicitType$ = "STRING"
				CASE '!'	: implicitType$ = "SINGLE"
				CASE '#'	: implicitType$ = "DOUBLE"
			END SELECT
			DEC pnmax
		END IF
	END IF
	IF pnmax < 0 THEN EXIT SUB 'no name before suffix
	IFF (nameChar[name${0}] & $Alpha_) THEN EXIT SUB 'invalid first character
	FOR p = 1 TO pnmax
		IFF (nameChar[name${p}] & $AlphaNumeric_) THEN EXIT SUB 'invalid char after first
	NEXT p
	OK = $$TRUE
END SUB

'constant name (after leading $$):
'  first  - any alpha-numeric character, or underscore
'  subsequent - any alpha-numeric character, or underscore
'  type suffix not allowed, except for single $
SUB ConstantName
	IF pnmax < 2 THEN EXIT SUB
	IFF (name${0}=='$')&(name${1}=='$') THEN EXIT SUB 'must start with $$
	IF name${pnmax} == '$' THEN
		IF pnmax < 3 THEN EXIT SUB
		implicitType$ = "STRING"
		DEC pnmax
	END IF

	FOR p = 2 TO pnmax
		IFF (nameChar[name${p}] & $AlphaNumeric_) THEN EXIT SUB 'invalid character
	NEXT p
	OK = $$TRUE
END SUB

SUB Init
'nameChar[] contains flags to indicate the category of a given
' character - alpha, numeric, underscore, or type suffix
	DIM nameChar[255]
	FOR i = 'A' TO 'Z'
		nameChar[i] = $Alpha
	NEXT i
	FOR i = 'a' TO 'z'
		nameChar[i] = $Alpha
	NEXT i
	nameChar['_'] = $Underscore
	FOR i = '0' TO '9'
		nameChar[i] = $Numeric
	NEXT i
	suffix$ = "@%&$~!#" 'type suffixes
	FOR i = 0 TO 6
		IF i <= 3 THEN
				nameChar[suffix${i}] = $Type1 | $Type2 'one or two suffix characters
			ELSE
				nameChar[suffix${i}] = $Type1 'one suffix character only
		END IF
	NEXT i
END SUB
END FUNCTION
'
' #########################
' #####  NameList ()  #####
' #########################
'
' Creates, maintains, and searches lists of names of constants, types, and functions
' Assumes the input name is syntactically correct.
'
' Lists are indexed by first 2 characters of name. This results in a significant
'  increase in search speed, at the expense of increased memory use. Indexing by
'  first 3 or more characters does not increase speed by much, but increases memory
'  requirements exponentially.
'
FUNCTION  NameList (nameIn$, symbolKind, mode)
	STATIC nameList$[]
	STATIC idx[]

	IF mode == $$InitList THEN
		GOSUB Init
		RETURN OK
	END IF

	IFZ idx[] THEN GOSUB Init
	IF (symbolKind < 0) | (symbolKind > UBOUND(nameList$[])) THEN RETURN
	IF symbolKind == $$Constant THEN
			name$ = MID$(nameIn$,3) 'remove leading $$
		ELSE
			name$ = nameIn$
	END IF
	IFZ nameIn$ THEN RETURN

	SELECT CASE mode
		CASE $$AddToList	: GOSUB AddName
		CASE $$SearchList	: GOSUB SearchList
	END SELECT
	RETURN OK

'add a name to the appropriate list, report error if already there
SUB AddName
	OK = $$TRUE
	idx0 = idx[name${0}]
	idx1 = idx[name${1}] 'will be 0 if name is only 1 character long
	SWAP nameList$[symbolKind, idx0, idx1,], temp$[]
	FOR i = 0 TO UBOUND(temp$[])
		IF name$ == temp$[i] THEN
			OK = $$FALSE 'duplicate
			EXIT FOR
		END IF
	NEXT i
	IF OK THEN 'add name to list
		REDIM temp$[i]
		temp$[i] = name$
	END IF
	SWAP temp$[], nameList$[symbolKind, idx0, idx1,]
END SUB

'search list for name, report error if not there
SUB SearchList
	OK = $$FALSE
	idx0 = idx[name${0}]
	idx1 = idx[name${1}]
	SWAP nameList$[symbolKind, idx0, idx1,], temp$[]
	FOR i = 0 TO UBOUND(temp$[])
		IF name$ == temp$[i] THEN 'found name in list
			OK = $$TRUE
			EXIT FOR
		END IF
	NEXT i
	SWAP temp$[], nameList$[symbolKind, idx0, idx1,]
END SUB

SUB Init
	DIM idx[255]
	maxIdx = 0

	FOR i = 'A' TO 'Z'
		INC maxIdx
		idx[i] = maxIdx
	NEXT i
	FOR i = 'a' TO 'z'
		INC maxIdx
		idx[i] = maxIdx
	NEXT i
	INC maxIdx
	idx['_'] = maxIdx

	FOR i = '0' TO '9'
		INC maxIdx
		idx[i] = maxIdx
	NEXT i

	suffix$ = "@%&$~!#" 'type suffixes
	FOR i = 0 TO 6
		INC maxIdx
		idx[suffix${i}] = maxIdx
	NEXT i

	DIM nameList$[2, maxIdx, maxIdx,]
	symbolKind = $$Type
	name$ = "UBYTE"			: GOSUB AddName
	name$ = "SBYTE"			: GOSUB AddName
	name$ = "USHORT"		: GOSUB AddName
	name$ = "SSHORT"		: GOSUB AddName
	name$ = "ULONG"			: GOSUB AddName
	name$ = "SLONG"			: GOSUB AddName
	name$ = "XLONG"			: GOSUB AddName
	name$ = "GIANT"			: GOSUB AddName
	name$ = "STRING"		: GOSUB AddName
	name$ = "SINGLE"		: GOSUB AddName
	name$ = "DOUBLE"		: GOSUB AddName
	name$ = "SCOMPLEX"	: GOSUB AddName
	name$ = "DCOMPLEX"	: GOSUB AddName
	name$ = "VOID"			: GOSUB AddName
	name$ = "ANY"				: GOSUB AddName
	name$ = "GOADDR"		: GOSUB AddName
	name$ = "SUBADDR"		: GOSUB AddName
	name$ = "FUNCADDR"	: GOSUB AddName
	OK = $$TRUE
END SUB
END FUNCTION
'
' ##############################
' #####  FuncAddrAlias ()  #####
' ##############################
'
' Maintains and searches a list of TYPE names which are aliases for FUNCADDR.
'
' This is necessary so that FUNCADDR aliases in type members are analyzed properly.
' Example:
'
'	TYPE CALLBACK = FUNCADDR
'
' TYPE FILE_OPS
'		CALLBACK	.read(XLONG, STRING)
'		CALLBACK	.write(XLONG, STRING)
'	END TYPE
'
FUNCTION  FuncAddrAlias (typeName$, mode)
	STATIC alias$[]

	IF mode == $$InitList THEN
		GOSUB Init
		RETURN OK
	END IF

	IFZ alias$[] THEN GOSUB Init
	IFZ typeName$ THEN RETURN

	SELECT CASE mode
		CASE $$AddToList	: GOSUB AddToList
		CASE $$SearchList	: GOSUB SearchList
	END SELECT
	RETURN OK

SUB AddToList
	GOSUB SearchList
	IF OK THEN OK = $$FALSE: EXIT SUB 'error - already on list
	IF i > UBOUND(alias$[]) THEN REDIM alias$[i+10]
	alias$[i] = typeName$
	OK = $$TRUE
END SUB

SUB SearchList
	OK = $$FALSE
	FOR i = 0 TO UBOUND(alias$[])
		IFZ alias$[i] THEN EXIT FOR
		IF typeName$ == alias$[i] THEN
			OK = $$TRUE
			EXIT FOR
		END IF
	NEXT i
END SUB

SUB Init
	DIM alias$[9]
	alias$[0] = "FUNCADDR"
END SUB

END FUNCTION
'
' ######################
' #####  Error ()  #####
' ######################
'
' Called when an error occurs while parsing a line.
'
' This function does not return.  The exception is picked up by the exception
'  handler (SUB Except) in DecCheck(), and execution continues at the SyntaxError
'  label in that function.  This avoids the need to back out of a series of nested
'  SUB or function calls, repeatedly checking return values and error flags, in
'  order to get on to the next line in the DEC file.
'
FUNCTION  Error (exceptionCode, data$)

	IF data$ THEN
		DIM arg[0]
		arg[0] = &data$
	END IF

	IFZ exceptionCode THEN exceptionCode = #Syntax
	XstRaiseException (exceptionCode, $$ExceptionTypeWarning, @arg[])

END FUNCTION
'
' ##########################
' #####  IntegerOK ()  #####
' ##########################
'
' Returns TRUE if string$ represents an integer (except GIANT),
'  whose value is between lower and upper, inclusive.
'
' or if string$ is a declared constant
' (ToDo: is the value of the constant within the required range?)
'
FUNCTION  IntegerOK (string$, lower, upper)

	value$ = TRIM$(string$)
	IFZ value$ THEN RETURN

	IF NameOK (@value$, $$Constant, "") THEN
		IF NameList (@value$, $$Constant, $$SearchList) THEN RETURN $$TRUE
		Error (#UndeclaredConstant, @string$)
	END IF

'XstStringToNumber() fails if leading sign is followed by whitespace
	SELECT CASE value${0}
		CASE '+'	: value$ = "+" + TRIM$(LCLIP$(value$))
		CASE '-'	: value$ = "-" + TRIM$(LCLIP$(value$))
	END SELECT
			
	IF XstStringToNumber (@value$, 0, @end, @rtype, @value$$) < 0 THEN RETURN

	SELECT CASE rtype
		CASE $$SLONG, $$XLONG	: value = GLOW(value$$)
		CASE ELSE	: RETURN
	END SELECT

	IF (end < LEN(value$)) THEN 'might be a type suffix
		suffix$ = MID$(value$, end+1)
		SELECT CASE suffix$
			CASE "@", "@@", "%", "%%", "&", "&&", "~" 
			CASE ELSE	: RETURN
		END SELECT
	END IF

	IF (value < lower) OR (value > upper) THEN RETURN
	RETURN $$TRUE
END FUNCTION
'
' #############################
' #####  PrintMessage ()  #####
' #############################
'
' Default error reporting function
'
FUNCTION  PrintMessage (msg$)
	PRINT msg$
END FUNCTION

END PROGRAM