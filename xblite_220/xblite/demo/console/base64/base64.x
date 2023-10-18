'
' ####################
' #####  PROLOG  #####
' ####################
'
' Convert binary date to base64-encoded data, or vice-versa.
' Base64 is used in MIME messages - see rfc2045
' Ken Minogue
'
PROGRAM	"base64"
VERSION	"1.0000"
CONSOLE

IMPORT	"xst"
IMPORT	"xsx"

'composite types used to simplify encoding
TYPE TRIPLET
	UBYTE	.c
	UBYTE	.b
	UBYTE	.a
END TYPE

TYPE CONVERT
	UNION
		XLONG		.x
		TRIPLET	.t
	END UNION
END TYPE

DECLARE FUNCTION  Entry ()

EXPORT
DECLARE FUNCTION  BinToBase64 (ANY, base64$)
DECLARE FUNCTION  Base64ToBin (base64$, bin$)
END EXPORT

'table of characters for Base64 encoding
$$table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	IF LIBRARY(0) THEN RETURN

	binFile$ = "c:/xblite/images/pinky.jpg"
	mimeFile$ = "pinky.mime"

	XstLoadString (@binFile$, @bin$)

'convert to base64
	BinToBase64 (@bin$, @base64$)

'output converted file in lines not exceeding 76 characters (required by RFC 2045)
	lenCode = LEN(base64$)
	ubMime = ((lenCode + 75) / 76) - 1
	DIM base64$[ubMime]
	p = 1
	FOR i = 0 TO ubMime
		base64$[i] = MID$(base64$, p, 76)
		p = p + 76
	NEXT i
	XstSaveStringArrayCRLF(@mimeFile$, @base64$[])

	PRINT "Image file "; binFile$; " converted to base64 file "; mimeFile$

'convert MIME file to binary file
	XstLoadString (@mimeFile$, @base64$)
	Base64ToBin (@base64$, @bin$)
	XstSaveString ("pinky.jpg", bin$)

	PRINT "Base64 file "; mimeFile$; " converted to bin file "; "pinky.jpg"

	a$ = INLINE$ ("Press any key to quit > ")

END FUNCTION
'
' ############################
' #####  BinToBase64 ()  #####
' ############################
'
' Convert any binary string or UBYTE array to a base64-encoded string.
'
' First argument is treated as a UBYTE array, but function can also be called
'  with a string, as long as the argument type is declared ANY in the PROLOG.
'
FUNCTION  BinToBase64 (UBYTE bin[], base64$)
	CONVERT z
	STATIC table$

'bitfields for extracting 6-bit code indexes
	$bf1 = BITFIELD(6,18)
	$bf2 = BITFIELD(6,12)
	$bf3 = BITFIELD(6,6)
	$bf4 = BITFIELD(6,0)

'initialize code table
	IFZ table$ THEN table$ = $$table

	lenBin = UBOUND(bin[]) + 1					'number of octets in input string
	lenCode = 4 * ((lenBin + 2) / 3)		'required length of output string
	base64$ = CHR$('=', lenCode)				'create output string full of pad characters

'extract four 6-bit indexes from each group of three 8-bit bytes
	codePtr = 0
	FOR binPtr = 0 TO lenBin - 3 STEP 3
		z.t.a = bin[binPtr]
		z.t.b = bin[binPtr+1]
		z.t.c = bin[binPtr+2]
		base64${codePtr} = table${z.x{$bf1}}: INC codePtr
		base64${codePtr} = table${z.x{$bf2}}: INC codePtr
		base64${codePtr} = table${z.x{$bf3}}: INC codePtr
		base64${codePtr} = table${z.x{$bf4}}: INC codePtr
	NEXT binPtr

'clean up any remaining octets
	SELECT CASE binPtr
		CASE (lenBin-2)
			z.x = 0
			z.t.a = bin[lenBin-2]
			z.t.b = bin[lenBin-1]
			base64${codePtr} = table${z.x{$bf1}}: INC codePtr
			base64${codePtr} = table${z.x{$bf2}}: INC codePtr
			base64${codePtr} = table${z.x{$bf3}}
		CASE (lenBin-1)
			z.x = 0
			z.t.a = bin[lenBin-1]
			base64${codePtr} = table${z.x{$bf1}}: INC codePtr
			base64${codePtr} = table${z.x{$bf2}}
	END SELECT

END FUNCTION
'
'
' ############################
' #####  Base64ToBin ()  #####
' ############################
'
' Convert base64-encoded string to original binary data.
'
' Any characters not in the code table (defined in the PROLOG) are ignored. This
'  includes CRLF sequences, whitespace, etc.
'
FUNCTION  Base64ToBin (base64$, bin$)
	STATIC convert[]

	IFZ convert[] THEN GOSUB Init

	lenCode = LEN(base64$)	'always a multiple of 4
	bin$ = NULL$(lenCode)   'actually does not need to be this long

	codePtr = 0
	DO WHILE codePtr <= lenCode - 4
		GOSUB GetIndex	: i1 = index
		GOSUB GetIndex	: i2 = index
		GOSUB GetIndex	: i3 = index
		GOSUB GetIndex	: i4 = index
		bin${binPtr} =  (i1 << 2) | (i2 >> 4)					: INC binPtr
		bin${binPtr} = ((i2 << 4) | (i3 >> 2)) & 0xFF	: INC binPtr
		bin${binPtr} = ((i3 << 6) | i4       ) & 0xFF	: INC binPtr
	LOOP

	bin$ = LEFT$(bin$, binPtr)


SUB GetIndex
	index = 0
	DO WHILE codePtr < lenCode
		index = convert[base64${codePtr}]: INC codePtr
	LOOP UNTIL index
	IF index THEN DEC index
END SUB

'set up conversion table.
' convert[j] is the position (1-based) in $$table of the byte j, 0 if byte j is not in $$table
SUB Init
'table of characters for Base64 encoding
	table$ = $$table
	DIM convert[0xFF]
	FOR i = 0 TO LEN(table$) - 1
		convert[table${i}] = i + 1  'zero in convert[] indicates invalid character
	NEXT i
END SUB

END FUNCTION
END PROGRAM
