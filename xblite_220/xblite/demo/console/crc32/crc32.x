'
' ####################
' #####  PROLOG  #####
' ####################
'
' A program to calculate the 32-bit cyclic
' redundancy checksum (CRC-32) of any file.
'---
' CRC32 can be used to make a
' "digital fingerprint" of a file.
' With CRC32 you can ID a huge 20+ MB file
' with single 32-bit number like 7d9c42fb
' (hexadecimal notation) which would
' identify the contents of this file. If
' any changes are made to it, even
' modifying a single bit, a new CRC-32
' calculation would give a completely
' different reference number (say 3faa83bd).
'
PROGRAM	"crc32"
VERSION	"0.0003"
CONSOLE
'
IMPORT	"xst"
IMPORT	"xsx"
IMPORT	"kernel32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  GetCrc32 (string$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	filename$ = INLINE$ ("Enter file name > ")
	filename$ = TRIM$ (filename$)
	XstLoadString (filename$, @string$)
	crc = GetCrc32 (@string$)

	PRINT "GetCrc32: CRC32 for "; filename$; " = "; HEX$(crc)
	PRINT
  a$ = INLINE$ ("Press any key to quit >")

END FUNCTION
'
'
' #########################
' #####  GetCrc32 ()  #####
' #########################
'
FUNCTION  GetCrc32 (string$)

	STATIC ULONG table[]
	ULONG sum, n, a, b, magic
	UBYTE i, j, c
	STATIC entry
'
	IFZ string$ THEN RETURN ($$TRUE)

	IFZ entry THEN
		entry = $$TRUE
		DIM table[255]
		magic = 0xEDB88320
'
		FOR j = 0 TO 255
			sum = j
			FOR i = 0 TO 7
				IF (sum AND 1) THEN
					rum = sum
					sum = (sum >> 1) XOR magic
					bum = (rum >> 1) XOR 0xEDB88320
'					IF (sum != bum) THEN PRINT "sum : bum = "; HEX$(sum,8); " : "; HEX$(bum,8)
				ELSE
					sum = (sum >> 1)
				END IF
			NEXT i
			table[j] = sum
'			PRINT "table[" j "]=" HEXX$(sum)
		NEXT j
	END IF
'
	crc32 = 0xFFFFFFFF
'
	upp = LEN (string$) - 1
	FOR i = 0 TO upp
		c = string${i}
		crc32 = table[(crc32 XOR c) AND 0xFF] XOR (crc32>>8)
	NEXT i
'
	RETURN (crc32 XOR 0xFFFFFFFF)

END FUNCTION
END PROGRAM
