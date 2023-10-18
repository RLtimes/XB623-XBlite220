'
' ####################
' #####  PROLOG  #####
' ####################
'
' The following example implements three independent
' bidirectional linked lists with arrays.
'
PROGRAM	"linklist"
VERSION	"0.0002"
CONSOLE
'
IMPORT	"xst"
IMPORT	"xsx"
IMPORT	"xio"
'
'
' #####################################
' #####  declare data structures  #####  AKA user-defined types
' #####################################
'
TYPE TOKEN
	UBYTE		.kind				' kind of entity
	UBYTE		.size				' # of bytes in string
	UBYTE		.hash				' hash of bytes in string
	UBYTE		.alpha			' first byte in string - alphabetic
	ULONG		.symbol			' symbol number = entry in string array
	ULONG		.prevsize		' previous entry of this size
	ULONG		.nextsize		' next entry of this size
	ULONG		.prevhash		' previous entry with this hash
	ULONG		.nexthash		' next entry with this hash
	ULONG		.prevalpha	' previous entry with this first byte
	ULONG		.nextalpha	' next entry with this first byte
END TYPE
'
TYPE ENDS
	ULONG		.first			' first entry in linked list
	ULONG		.final			' final entry in linked list
END TYPE
'
'
' ###############################
' #####  declare functions  #####
' ###############################
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  ProcessSymbol (symbol$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
' The following example implements three independent
' bidirectional linked lists with arrays.
'
FUNCTION  Entry ()
	SHARED	symbol$[]
	SHARED  thisToken
	SHARED  upperToken
	SHARED	TOKEN  token[]
	SHARED	ENDS  alpha[]
	SHARED	ENDS  size[]
	SHARED	ENDS  hash[]
'
' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 200)
	XioCloseStdHandle (hStdOut)
'
	XstLoadStringArray ("raw.txt", @text$[])
	IFZ text$[] THEN RETURN
'
	upper = UBOUND (text$[])
'
' trim leading and trailing whitespace from each line of text
'
	last = -1											' last non-empty line
	FOR i = 0 TO upper
		text$[i] = TRIM$(text$[i])	' remove leading/trailing whitespace
		IF text$[i] THEN last = i		' non-empty line
	NEXT i
	IF (last < 0) THEN RETURN			' no non-empty lines
'
' remove empty lines from end of file, if any
'
	IF (last != upper) THEN
		REDIM text$[last]						' clip off empty lines at the end
		upper = last
	END IF
'
' initialize variables and arrays to hold symbols, tokens, list-ends
'
	thisToken = 0										' start with 0 tokens
	upperToken = 65535							' maximum of 65536 tokens
	DIM token[upperToken]						' create array to hold tokens
	DIM symbol$[upperToken]					' create array to hold symbols
	DIM alpha[255]									' up to 255 first characters
	DIM hash[255]										' up to 255 hash values
	DIM size[255]										' up to 255 sizes
'
' collect symbols from every line
'
	FOR line = 0 TO upper						' for all lines of text
		SWAP text$[line], line$				' line$ = line of text
		IFZ line$ THEN DO NEXT				' skip empty lines
		done = $$FALSE								' not done checking line yet
		index = 0											' start at 1st character in line
'
' collect and process every symbol in the current line$
'
		DO
			symbol$ = XstNextField$ (@line$, @index, @done)
			IF symbol$ THEN
				INC thisToken
				IF (thisToken > upperToken) THEN
					upperToken = upperToken + 65536
					REDIM symbol$[upperToken]
					REDIM token[upperToken]
				END IF
				symbol$[thisToken] = symbol$
				ProcessSymbol (@symbol$)
			END IF
			IF done THEN EXIT DO
		LOOP WHILE symbol$
		SWAP line$, text$[line]				' text$[line] = line of text
	NEXT line
'
' print some results as a test
'
	PRINT
	PRINT "#####  increasing size  #####"
	PRINT
	FOR size = 0 TO 255
		first = size[size].first
		final = size[size].final
		IFZ first THEN
'			PRINT HEX$(size,2);; HEX$(first,4);; HEX$(final,4)
		ELSE
			PRINT HEX$(size,2);; HEX$(first,4);; HEX$(final,4);;; LJUST$(symbol$[first],28);;; LJUST$(symbol$[final],28)
		END IF
	NEXT size
'
	PRINT
	PRINT "#####  increasing hash  #####"
	PRINT

	FOR hash = 0 TO 255
		first = hash[hash].first
		final = hash[hash].final
		IFZ first THEN
'			PRINT HEX$(hash,2);; HEX$(first,4);; HEX$(final,4)
		ELSE
			PRINT HEX$(hash,2);; HEX$(first,4);; HEX$(final,4);;; LJUST$(symbol$[first],28);;; LJUST$(symbol$[final],28)
		END IF
	NEXT hash
'
	PRINT
	PRINT "#####  increasing alpha  #####"
	PRINT
	FOR alpha = 0 TO 255
		first = alpha[alpha].first
		final = alpha[alpha].final
		IFZ first THEN
'			PRINT HEX$(alpha,2);; HEX$(first,4);; HEX$(final,4)
		ELSE
			PRINT HEX$(alpha,2);; HEX$(first,4);; HEX$(final,4);;; LJUST$(symbol$[first],28);;; LJUST$(symbol$[final],28)
		END IF
	NEXT alpha
'
	PRINT
	PRINT "#####  walk some size links  #####"
	PRINT
	FOR size = 1 TO 16
		first = size[size].first
		final = size[size].final
		token = first
'
		DO WHILE token
			next = token[token].nextsize
			PRINT HEX$(size,2);; HEX$(token,4);; HEX$(next,4);;; symbol$[token]
			token = next
		LOOP
	NEXT size
	
	PRINT
	a$ = INLINE$("Press ENTER to exit >")
	RETURN
END FUNCTION
'
'
' ##############################
' #####  ProcessSymbol ()  #####
' ##############################
'
FUNCTION  ProcessSymbol (symbol$)
	SHARED	symbol$[]
	SHARED  thisToken
	SHARED  upperToken
	SHARED	TOKEN  token[]
	SHARED	ENDS  alpha[]
	SHARED	ENDS  size[]
	SHARED	ENDS  hash[]
'
	IFZ symbol$ THEN RETURN								' empty symbol
'
' compute basis of three linked lists
'
	alpha = symbol${0}										' 1st byte in symbol
	size = LEN (symbol$)									' size of symbol in bytes
	IF (size > 255) THEN size = 255				' set functional size limit
	hash = 0															' clear hash value
	FOR char = 0 TO size-1								' for all bytes in symbol
		hash = hash + symbol${char}					' accumulate hash value
		hash = hash & 0x00FF								' max hash = 0x00FF
	NEXT char
'
' add bidirectional links based on first character in symbol - alpha
'
	first = alpha[alpha].first						' first entry in alpha linked list
	final = alpha[alpha].final						' final entry in alpha linked list
	alpha[alpha].final = thisToken				' this entry is new final alpha entry
	IFZ first THEN alpha[alpha].first = thisToken
	IF final THEN token[final].nextalpha = thisToken
	token[thisToken].prevalpha = final		' prev alpha entry was final alpha entry
	token[thisToken].nextalpha = 0				' this is the new final alpha entry
'
' add bidirectional links based on size of symbol
'
	first = size[size].first						' first entry in size linked list
	final = size[size].final						' final entry in size linked list
	size[size].final = thisToken				' this entry is new final size entry
	IFZ first THEN size[size].first = thisToken
	IF final THEN token[final].nextsize = thisToken
	token[thisToken].prevsize = final		' prev size entry was final size entry
	token[thisToken].nextsize = 0				' this is the new final size entry
'
' add bidirectional links based on simple hash of symbol
'
	first = hash[hash].first						' first entry in hash linked list
	final = hash[hash].final						' final entry in hash linked list
	hash[hash].final = thisToken				' this entry is new final hash entry
	IFZ first THEN hash[hash].first = thisToken
	IF final THEN token[final].nexthash = thisToken
	token[thisToken].prevhash = final		' prev hash entry was final hash entry
	token[thisToken].nexthash = 0				' this is the new final hash entry
END FUNCTION
END PROGRAM
