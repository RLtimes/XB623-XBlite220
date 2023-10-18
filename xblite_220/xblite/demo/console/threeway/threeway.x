'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' C specification of the threeway block cipher
' http://home.ecn.ab.ca/~jsavard/crypto/co040307.htm
' XBasic port by Vic Drastik
'
PROGRAM "threeway"
VERSION	"0.0001"
CONSOLE

TYPE word32=XLONG

DECLARE FUNCTION VOID Entry()
DECLARE FUNCTION VOID mu(word32 a[])
DECLARE FUNCTION VOID gamma(word32 a[])
DECLARE FUNCTION VOID theta(word32 a[])
DECLARE FUNCTION VOID pi_1(word32 a[])
DECLARE FUNCTION VOID pi_2(word32 a[])
DECLARE FUNCTION VOID rho(word32 a[])
DECLARE FUNCTION VOID rndcon_gen(word32 strt , word32 rtab[])
DECLARE FUNCTION VOID encrypt(word32 a[] , word32 k[])
DECLARE FUNCTION VOID decrypt(word32 a[] , word32 k[])
DECLARE FUNCTION VOID printvec(word32 a[])


$$STRT_E = 0x0b0b ' round constant of first encryption round
$$STRT_D = 0xb1b1 ' round constant of first decryption round
$$NMBR   =     11 ' number of rounds is 11


FUNCTION VOID mu(word32 a[]) ' inverts the order of the bits of a[]
SSHORT i
word32 b[3]

b[0] = 0 : b[1] = 0 : b[2] = 0
FOR i = 0 TO 31
  b[0] = b[0] << 1 : b[1] = b[1] << 1 : b[2] = b[2] << 1
  IF a[0] & 1 THEN b[2] = b[2] | 1
  IF a[1] & 1 THEN b[1] = b[1] | 1
  IF a[2] & 1 THEN b[0] = b[0] | 1
  a[0] = a[0] >> 1 : a[1] = a[1] >> 1 : a[2] = a[2] >> 1
NEXT i

a[0] = b[0] : a[1] = b[1] : a[2] = b[2]
END FUNCTION



FUNCTION VOID gamma(word32 a[]) ' the nonlinear step
word32 b[3]

b[0] = a[0] ^ (a[1]|(~a[2]))
b[1] = a[1] ^ (a[2]|(~a[0]))
b[2] = a[2] ^ (a[0]|(~a[1]))

a[0] = b[0] : a[1] = b[1] : a[2] = b[2]
END FUNCTION



FUNCTION VOID theta(word32 a[]) ' the linear step
word32 b[3]

b[0] = a[0] ^ (a[0]>>16) ^ (a[1]<<16) ^ (a[1]>>16) ^ (a[2]<<16) ^ (a[1]>>24) ^ (a[2]<<8) ^ (a[2]>>8) ^ (a[0]<<24) ^ (a[2]>>16) ^ (a[0]<<16) ^ (a[2]>>24) ^ (a[0]<<8)
b[1] = a[1] ^ (a[1]>>16) ^ (a[2]<<16) ^ (a[2]>>16) ^ (a[0]<<16) ^ (a[2]>>24) ^ (a[0]<<8) ^ (a[0]>>8) ^ (a[1]<<24) ^ (a[0]>>16) ^ (a[1]<<16) ^ (a[0]>>24) ^ (a[1]<<8)
b[2] = a[2] ^ (a[2]>>16) ^ (a[0]<<16) ^ (a[0]>>16) ^ (a[1]<<16) ^ (a[0]>>24) ^ (a[1]<<8) ^ (a[1]>>8) ^ (a[2]<<24) ^ (a[1]>>16) ^ (a[2]<<16) ^ (a[1]>>24) ^ (a[2]<<8)

a[0] = b[0] : a[1] = b[1] : a[2] = b[2]
END FUNCTION



FUNCTION VOID pi_1(word32 a[])
a[0] = (a[0]>>10) ^ (a[0]<<22)
a[2] = (a[2]<<1)  ^ (a[2]>>31)
END FUNCTION



FUNCTION VOID pi_2(word32 a[])
a[0] = (a[0]<<1)  ^ (a[0]>>31)
a[2] = (a[2]>>10) ^ (a[2]<<22)
END FUNCTION



FUNCTION VOID rho(word32 a[]) ' the round function
theta(@a[])
pi_1 (@a[])
gamma(@a[])
pi_2 (@a[])
END FUNCTION



FUNCTION VOID rndcon_gen(word32 strt , word32 rtab[])
' generates the round constants
SSHORT i

FOR i = 0 TO $$NMBR
  rtab[i] = strt
  strt = strt << 1
  IF strt & 0x10000 THEN strt = strt ^ 0x11011
NEXT i
END FUNCTION



FUNCTION VOID encrypt(word32 a[] , word32 k[])
SBYTE i
word32 rcon[$$NMBR+1]

rndcon_gen($$STRT_E , @rcon[])
FOR i = 0 TO $$NMBR - 1
  a[0] = a[0] ^ k[0] ^ (rcon[i]<<16)
  a[1] = a[1] ^ k[1]
  a[2] = a[2] ^ k[2] ^ rcon[i]
  rho(@a[])
NEXT i
a[0] = a[0] ^ k[0] ^ (rcon[$$NMBR]<<16)
a[1] = a[1] ^ k[1]
a[2] = a[2] ^ k[2] ^ rcon[$$NMBR]
theta(@a[])
END FUNCTION



FUNCTION VOID decrypt(word32 a[], word32 k[])
SBYTE i
word32 ki[3]           ' the "inverse" key
word32 rcon[$$NMBR+1]  ' the "inverse" round constants

ki[0] = k[0] : ki[1] = k[1] : ki[2] = k[2]
theta(@ki[])
mu(@ki[])

rndcon_gen($$STRT_D , @rcon[])

mu(@a[])
FOR i = 0 TO $$NMBR - 1
  a[0] = a[0] ^ ki[0] ^ (rcon[i]<<16)
  a[1] = a[1] ^ ki[1]
  a[2] = a[2] ^ ki[2] ^ rcon[i]
  rho(@a[])
NEXT i
a[0] = a[0] ^ ki[0] ^ (rcon[$$NMBR]<<16)
a[1] = a[1] ^ ki[1]
a[2] = a[2] ^ ki[2] ^ rcon[$$NMBR]
theta(@a[])
mu(@a[])
END FUNCTION




FUNCTION VOID printvec(word32 a[])
  PRINT HEX$(a[2],8) , HEX$(a[1],8) , HEX$(a[0],8)
END FUNCTION



' TEST VALUES
' key        : 00000000 00000000 00000000
' plaintext  : 00000001 00000001 00000001
' ciphertext : ad21ecf7 83ae9dc4 4059c76e
'
' key        : 00000004 00000005 00000006
' plaintext  : 00000001 00000002 00000003
' ciphertext : cab920cd d6144138 d2f05b5e
'
' key        : bcdef012 456789ab def01234
' plaintext  : 01234567 9abcdef0 23456789
' ciphertext : 7cdb76b2 9cdddb6d 0aa55dbb
'
' key        : cab920cd d6144138 d2f05b5e
' plaintext  : ad21ecf7 83ae9dc4 4059c76e
' ciphertext : 15b155ed 6b13f17c 478ea871

FUNCTION VOID Entry()

word32 a[3], k[3]

PRINT "Three-way encrypt/decrypt"
k[2] = 0xbcdef012 : k[1] = 0x456789ab : k[0] = 0xdef01234
a[2] = 0x01234567 : a[1] = 0x9abcdef0 : a[0] = 0x23456789


PRINT "key        : "; : printvec(@k[])
PRINT "plaintext  : "; : printvec(@a[]) : encrypt(@a[] , @k[])
PRINT "ciphertext : "; : printvec(@a[]) : decrypt(@a[] , @k[])
PRINT "checking   : "; : printvec(@a[])

PRINT
a$ = INLINE$ ("Press any key to QUIT >") ' pauses until a key is pressed

END FUNCTION
END PROGRAM
