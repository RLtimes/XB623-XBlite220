'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' TEA, a Tiny Encryption Algorithm
' David Wheeler, Roger Needham
' Computer Laboratory, Cambridge University
' England, November 1994
' ++++
' XBasic port by Vic Drastic
' For most purposes, TEA is the best algorithm
' because it requires no initialisation.
' It is cheap to use, has variable-key encryption,
' and is unbreakable by any publicly-known methods.
' It uses an 128-bit key to encrypt a 64-bit block
' of data.
'
PROGRAM "tea"
VERSION	"0.0001"
CONSOLE

'IMPORT "xst"

DECLARE FUNCTION VOID Entry ()
DECLARE FUNCTION VOID TeaEncrypt(XLONG plain [] , XLONG key[])
DECLARE FUNCTION VOID TeaDecrypt(XLONG cipher[] , XLONG key[])


FUNCTION  Entry()
XLONG plain[] , cipher[] , key[]

DIM plain[1] , cipher[1] , key[3]

plain[0] = 0x44434241
plain[1] = 0x48474645

PRINT "plaintext = "; HEX$(plain[0],8) , HEX$(plain[1],8)

FOR i = 0 TO 3
  key[i] = i*i
NEXT i

TeaEncrypt(@plain[],@key[])
PRINT "Ciphertext = "; HEX$(plain[0],8), HEX$(plain[1],8)

TeaDecrypt(@plain[],@key[])
PRINT "Decrypted Plaintext = "; HEX$(plain[0],8), HEX$(plain[1],8)

PRINT
a$ = INLINE$("Press any key to QUIT >")

END FUNCTION



FUNCTION VOID TeaEncrypt(XLONG plain[] , XLONG key[])
XLONG y , z , sum , i
y = plain[0] : z = plain[1]

sum   = 0
FOR i = 0 TO 31
  sum = sum + 0x9E3779B9
  y = y + ( ((z<<4)+key[0]) ^ (z+sum) ^ ((z>>5)+key[1]) )
  z = z + ( ((y<<4)+key[2]) ^ (y+sum) ^ ((y>>5)+key[3]) )
NEXT i

plain[0]=y : plain[1]=z
END FUNCTION


FUNCTION VOID TeaDecrypt(XLONG cipher[], XLONG key[])
XLONG y , z , sum , i
y = cipher[0] :  z = cipher[1]

sum = (0x9E3779B9)<<5

FOR i = 0 TO 31
  z = z - ( ((y<<4)+key[2]) ^ (y+sum) ^ ((y>>5)+key[3]) )
  y = y - ( ((z<<4)+key[0]) ^ (z+sum) ^ ((z>>5)+key[1]) )
  sum = sum - 0x9E3779B9
NEXT i

cipher[0] = y : cipher[1] = z
END FUNCTION
END PROGRAM
