'
'
' ####################
' #####  PROLOG  #####
' ####################
'
'-- MD5 CheckSum Algorithm
'-- The official description of the MD5 algorithm can be found at
'-- ftp://ftp.rsa.com/pub/md5.txt
'-- License is granted by RSA Data Security, Inc.
'-- http://www.rsa.com
'-- to make and use derivative works provided that such works are
'-- identified as "derived from the RSA Data Security, Inc.
'-- MD5 Message-Digest Algorithm" in all material mentioning or referencing
'-- the derived work. (See the copyright notice in the official description.)
'-- md5.x is a conversion of an Ada MD5 program to Xbasic by Vic Drastik

PROGRAM "md5"
VERSION "1.0000"
CONSOLE

'	IMPORT	"xst"   ' Standard library : required by most programs

DECLARE FUNCTION VOID   Entry()
DECLARE FUNCTION XLONG  F(XLONG x , XLONG y , XLONG z)
DECLARE FUNCTION XLONG  G(XLONG x , XLONG y , XLONG z)
DECLARE FUNCTION XLONG  H(XLONG x , XLONG y , XLONG z)
DECLARE FUNCTION XLONG  I(XLONG x , XLONG y , XLONG z)
DECLARE FUNCTION VOID   FF(a,b,c,d,x,s,k)
DECLARE FUNCTION VOID   GG(a,b,c,d,x,s,k)
DECLARE FUNCTION VOID   HH(a,b,c,d,x,s,k)
DECLARE FUNCTION VOID   II(a,b,c,d,x,s,k)
DECLARE FUNCTION STRING MD5(UBYTE u[])
DECLARE FUNCTION VOID   StringToArray(STRING s , UBYTE u[])

FUNCTION  Entry ()
UBYTE  u[]
STRING u$[]

DIM u$[6]
u$[0] = ""
u$[1] = "a"
u$[2] = "abc"
u$[3] = "message digest"
u$[4] = "abcdefghijklmnopqrstuvwxyz"
u$[5] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
u$[6] = "12345678901234567890123456789012345678901234567890123456789012345678901234567890"

FOR i = 0 TO 6
  StringToArray(u$[i] , @u[])
  PRINT "MD5 checksum of " ; u$[i] ; " is:"
	PRINT MD5(@u[])
	PRINT
NEXT i

PRINT
a$ = INLINE$ ("Press any key to exit >")

END FUNCTION
FUNCTION XLONG F(XLONG x , XLONG y , XLONG z)
RETURN (x & y) | ((~x) & z)
END FUNCTION
FUNCTION XLONG G(XLONG x , XLONG y , XLONG z)
RETURN (x & z) | (y & (~z))
END FUNCTION
FUNCTION XLONG H(XLONG x , XLONG y , XLONG z)
RETURN x ^ y ^ z
END FUNCTION
FUNCTION XLONG I(XLONG x , XLONG y , XLONG z)
RETURN y ^ (x | (~z))
END FUNCTION
FUNCTION VOID FF(a,b,c,d,x,s,k)
a = b + ROTATEL(a + F(b,c,d) + x + k , s)
END FUNCTION
FUNCTION VOID GG(a,b,c,d,x,s,k)
a = b + ROTATEL(a + G(b,c,d) + x + k , s)
END FUNCTION
FUNCTION VOID HH(a,b,c,d,x,s,k)
a = b + ROTATEL(a + H(b,c,d) + x + k , s)
END FUNCTION
FUNCTION VOID II(a,b,c,d,x,s,k)
a = b + ROTATEL(a + I(b,c,d) + x + k , s)
END FUNCTION

FUNCTION STRING MD5(UBYTE u[])
'
' This function calculates the MD5 of the byte array u[]
' and returns it as a string of length 32
'
XLONG  a,b,c,d,X[],state[],n,k,r,block,m
UBYTE  v[]
GIANT  g
STRING s

GOSUB  Initialise
GOSUB  DoBlocks
GOSUB  IncompleteBlock
GOSUB  Convert
RETURN s



SUB Initialise
DIM X[15] , state[3] , v[63]

' set initial state to magic constants
state[0] = 0x67452301
state[1] = 0xEfCDAB89
state[2] = 0x98BADCFE
state[3] = 0x10325476

' n is the number of bytes in u[]
n = 1 + UBOUND(u[])

' k is the number of complete 64-byte blocks in u[]
k = n \ 64

' r is the length of the last (incomplete) block
r = n - 64 * k
END SUB



SUB DoBlocks
' First transform all the complete blocks (possibly zero)
FOR block = 1 TO k
  b = 64 * (block - 1)
  FOR m = 0 TO 60 STEP 4
    X[m>>2] = u[b+m+0]|u[b+m+1]<<8|u[b+m+2]<<16|u[b+m+3]<<24
  NEXT m
  GOSUB MD5Transform
NEXT block
END SUB


SUB IncompleteBlock
' This leaves us with 1 incomplete block.
' if  0 <= r <= 55 we pad and transform once
' if 56 <= r <= 63 we pad and transform twice

IF r < 56 THEN GOSUB Once ELSE GOSUB Twice
END SUB



SUB Convert
s = ""
FOR i = 0 TO 3
  FOR j = 0 TO 24 STEP 8
    s = s + HEX$( state[i]{8,j} , 2)
  NEXT j
NEXT i
END SUB



SUB Once
'put remaining bytes into v[]
FOR i = 64*k TO n-1
  v[i-64*k] = u[i]
NEXT i

'pad with 0b10000000
v[r] = 0b10000000

'pad with zeroes , if possible
FOR i = r+1 TO 55
  v[i] = 0
NEXT i

' convert ubyte to xlong
FOR i = 0 TO 52 STEP 4
  X[i>>2] = v[i+0]|v[i+1]<<8|v[i+2]<<16|v[i+3]<<24
NEXT i

' calculate number of bits in u[]
g = 8 * GIANT(n)
X[14] = GLOW (g)
X[15] = GHIGH(g)

GOSUB MD5Transform
END SUB



SUB Twice
'put remaining bytes into v[]
FOR i = 64*k TO n-1
  v[i-64*k] = u[i]
NEXT i

'pad with 0b10000000
v[r] = 0b10000000

'pad with zeroes , if possible
FOR i = r+1 TO 63
  v[i] = 0
NEXT i

' convert ubyte to xlong
FOR i = 0 TO 60 STEP 4
  X[i>>2] = v[i+0]|v[i+1]<<8|v[i+2]<<16|v[i+3]<<24
NEXT i

'transform for the first time
GOSUB MD5Transform

'pad with zeroes
FOR i = 0 TO 13
  X[i] = 0
NEXT i

' calculate number of bits in u[]
g = 8 * GIANT(n)
X[14] = GLOW (g)
X[15] = GHIGH(g)

'transform for the second time
GOSUB MD5Transform
END SUB




SUB MD5Transform
a = state[0]
b = state[1]
c = state[2]
d = state[3]

'Round 1
FF(@a, b, c, d, X[ 0],  7, 0xD76AA478)
FF(@d, a, b, c, X[ 1], 12, 0xE8C7B756)
FF(@c, d, a, b, X[ 2], 17, 0x242070DB)
FF(@b, c, d, a, X[ 3], 22, 0xC1BDCEEE)
FF(@a, b, c, d, X[ 4],  7, 0xF57C0FAF)
FF(@d, a, b, c, X[ 5], 12, 0x4787C62A)
FF(@c, d, a, b, X[ 6], 17, 0xA8304613)
FF(@b, c, d, a, X[ 7], 22, 0xFD469501)
FF(@a, b, c, d, X[ 8],  7, 0x698098D8)
FF(@d, a, b, c, X[ 9], 12, 0x8B44F7AF)
FF(@c, d, a, b, X[10], 17, 0xFFFF5BB1)
FF(@b, c, d, a, X[11], 22, 0x895CD7BE)
FF(@a, b, c, d, X[12],  7, 0x6B901122)
FF(@d, a, b, c, X[13], 12, 0xFD987193)
FF(@c, d, a, b, X[14], 17, 0xA679438E)
FF(@b, c, d, a, X[15], 22, 0x49B40821)


'Round 2
GG(@a, b, c, d, X[ 1],  5, 0xF61E2562)
GG(@d, a, b, c, X[ 6],  9, 0xC040B340)
GG(@c, d, a, b, X[11], 14, 0x265E5A51)
GG(@b, c, d, a, X[ 0], 20, 0xE9B6C7AA)
GG(@a, b, c, d, X[ 5],  5, 0xD62F105D)
GG(@d, a, b, c, X[10],  9, 0x02441453)
GG(@c, d, a, b, X[15], 14, 0xD8A1E681)
GG(@b, c, d, a, X[ 4], 20, 0xE7D3FBC8)
GG(@a, b, c, d, X[ 9],  5, 0x21E1CDE6)
GG(@d, a, b, c, X[14],  9, 0xC33707D6)
GG(@c, d, a, b, X[ 3], 14, 0xF4D50D87)
GG(@b, c, d, a, X[ 8], 20, 0x455A14ED)
GG(@a, b, c, d, X[13],  5, 0xA9E3E905)
GG(@d, a, b, c, X[ 2],  9, 0xFCEFA3F8)
GG(@c, d, a, b, X[ 7], 14, 0x676F02D9)
GG(@b, c, d, a, X[12], 20, 0x8D2A4C8A)


'Round 3
HH(@a, b, c, d, X[ 5],  4, 0xFFFA3942)
HH(@d, a, b, c, X[ 8], 11, 0x8771F681)
HH(@c, d, a, b, X[11], 16, 0x6D9D6122)
HH(@b, c, d, a, X[14], 23, 0xFDE5380C)
HH(@a, b, c, d, X[ 1],  4, 0xA4BEEA44)
HH(@d, a, b, c, X[ 4], 11, 0x4BDECFA9)
HH(@c, d, a, b, X[ 7], 16, 0xF6BB4B60)
HH(@b, c, d, a, X[10], 23, 0xBEBFBC70)
HH(@a, b, c, d, X[13],  4, 0x289B7EC6)
HH(@d, a, b, c, X[ 0], 11, 0xEAA127FA)
HH(@c, d, a, b, X[ 3], 16, 0xD4EF3085)
HH(@b, c, d, a, X[ 6], 23, 0x04881D05)
HH(@a, b, c, d, X[ 9],  4, 0xD9D4D039)
HH(@d, a, b, c, X[12], 11, 0xE6DB99E5)
HH(@c, d, a, b, X[15], 16, 0x1FA27CF8)
HH(@b, c, d, a, X[ 2], 23, 0xC4AC5665)


'Round 4
II(@a, b, c, d, X[ 0],  6, 0xF4292244)
II(@d, a, b, c, X[ 7], 10, 0x432AFF97)
II(@c, d, a, b, X[14], 15, 0xAB9423A7)
II(@b, c, d, a, X[ 5], 21, 0xFC93A039)
II(@a, b, c, d, X[12],  6, 0x655B59C3)
II(@d, a, b, c, X[ 3], 10, 0x8F0CCC92)
II(@c, d, a, b, X[10], 15, 0xFFEFF47D)
II(@b, c, d, a, X[ 1], 21, 0x85845DD1)
II(@a, b, c, d, X[ 8],  6, 0x6FA87E4F)
II(@d, a, b, c, X[15], 10, 0xFE2CE6E0)
II(@c, d, a, b, X[ 6], 15, 0xA3014314)
II(@b, c, d, a, X[13], 21, 0x4E0811A1)
II(@a, b, c, d, X[ 4],  6, 0xF7537E82)
II(@d, a, b, c, X[11], 10, 0xBD3AF235)
II(@c, d, a, b, X[ 2], 15, 0x2AD7D2BB)
II(@b, c, d, a, X[ 9], 21, 0xEB86D391)

'update state array
state[0] = state[0] + a
state[1] = state[1] + b
state[2] = state[2] + c
state[3] = state[3] + d
END SUB
END FUNCTION
'
'
' ##############################
' #####  StringToArray ()  #####
' ##############################
'
FUNCTION VOID StringToArray(STRING s , UBYTE u[])
XLONG i
n = UBOUND(s)
DIM u[n]

FOR i = 0 TO n
  u[i] = s{i}
NEXT i

END FUNCTION
END PROGRAM
