'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Implementation of RC4 encyption algorithm.
' RC4 is a trademark of RSA Labs, so you cannot
' freely use the algorithm under that name.
' Since the RC4 algorithm is unpatented, and,
' in fact, not formally known, you may use what is
' alleged to be the RC4 algorithm (hence ARC4 or
' ARCFOUR) freely as long as you call it something else.
' Vic Drastik
'
PROGRAM	"arc4"
VERSION	"0.0001"
CONSOLE

IMPORT "xst"
IMPORT "xio"

TYPE RC4_STATE
	XLONG .x
	XLONG	.y
	XLONG	.m[255]
END TYPE

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  PrintData (data$)
DECLARE FUNCTION  rc4_encrypt (key$, in$, @out$)
DECLARE FUNCTION  rc4_decrypt (key$, in$, @out$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 50)
	XioCloseStdHandle (hStdOut)

' test data

	key$       = "\x01\x23\x45\x67\x89\xab\xcd\xef"
	plaintext$ = "\x01\x23\x45\x67\x89\xab\xcd\xef"
	out$       = "\x75\xb7\x87\x80\x99\xe0\xc5\x96"

	key$       = "\x01\x23\x45\x67\x89\xab\xcd\xef"
	plaintext$ = "\x00\x00\x00\x00\x00\x00\x00\x00"
	out$       = "\x74\x94\xc2\xe7\x10\x4b\x08\x79"

	key$       = "\x00\x00\x00\x00\x00\x00\x00\x00"
	plaintext$ = "\x00\x00\x00\x00\x00\x00\x00\x00"
	out$       = "\xde\x18\x89\x41\xa3\x37\x5d\x3a"

	key$       = "\xef\x01\x23\x45"
	plaintext$ = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
	out$       = "\xd6\xa1\x41\xa7\xec\x3c\x38\xdf\xbd\x61\x5a\x11\x62\xe1\xc7\xba\x36\xb6\x78\x58"

	key$ = "Alice in Wonderland"
	plaintext$ = "In the morning my sister and I were having our porridge, mapping little rivers on its surface for the milk to follow."

	rc4_encrypt (key$, plaintext$, @ciphertext$)
	PrintData (plaintext$)
	PRINT
	PrintData (ciphertext$)
	PRINT
	PRINT ciphertext$

	rc4_decrypt (key$, ciphertext$, @plaintext$)
	PRINT
	PrintData (plaintext$)
	PRINT
	PRINT plaintext$

	PRINT
	a$ = INLINE$ ("Press any key to QUIT >")


END FUNCTION
'
'
' ##########################
' #####  PrintData ()  #####
' ##########################
'
FUNCTION  PrintData (data$)

	IFZ data$ THEN RETURN ($$TRUE)

	upp = UBOUND (data$)

	FOR i = 0 TO upp
		PRINT HEXX$ (data${i});;
	NEXT i


END FUNCTION
'
'
' ############################
' #####  rc4_encrypt ()  #####
' ############################
'
FUNCTION  rc4_encrypt (key$, in$, @out$)

	RC4_STATE s

	IFZ key$ THEN RETURN ($$TRUE)
	IFZ in$ THEN RETURN ($$TRUE)

	GOSUB Initialize

	out$ = in$

	x = s.x
	y = s.y

	upper = UBOUND (in$)

	FOR i = 0 TO upper
		x = (x + 1) AND 0xFF
		y = (y + s.m[x]) AND 0xFF

		SWAP s.m[y], s.m[x]

		out${i} = out${i} ^ s.m[(s.m[x] + s.m[y]) AND 0xFF]
	NEXT i

	s.x = x
	s.y = y

	RETURN

' ***** Initialize *****
SUB Initialize

	s.x = 0
	s.y = 0

	FOR i = 0 TO 255
 		s.m[i] = i
	NEXT i

	j = 0

	keylength = LEN (key$)

	FOR i = 0 TO 255
		j = (j + s.m[i] + key${i MOD keylength}) AND 0xFF
		SWAP s.m[i], s.m[j]
	NEXT i

END SUB


END FUNCTION
'
'
' ############################
' #####  rc4_decrypt ()  #####
' ############################
'
FUNCTION  rc4_decrypt (key$, in$, @out$)

	rc4_encrypt (key$, in$, @out$)


END FUNCTION
END PROGRAM
