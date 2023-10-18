'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Creating a Hash From File Content
' The following example demonstrates using
' CryptoAPI functions in advapi32.dll
' to compute the hash (checksum) of the contents
' of a file. One of three possible hashing
' algorithms, MD2, MD5 or SHA can be selected.
' Note that the SHA-1 hash algorithm has been
' determined to be compromised by Chinese
' researchers:
' http://www.cbronline.com/article_news.asp?guid=80B85141-EC06-4E58-9E10-497A4E1AF75F

PROGRAM	"hashfile"
VERSION	"0.0001"
CONSOLE
'
'	IMPORT	"xst"
	IMPORT	"kernel32"
	IMPORT	"advapi32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  CreateHash (fileName$, algID, @hash$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

	fileName$ = "c:\\autoexec.bat"

	CreateHash (fileName$, $$CALG_MD2, @hash$)
	PRINT "MD2 hash of file "; fileName$; " is : "
	PRINT "hash$ = "; hash$
	PRINT

	CreateHash (fileName$, $$CALG_MD5, @hash$)
	PRINT "MD5 hash of file "; fileName$; " is : "
	PRINT "hash$ = "; hash$
	PRINT

	CreateHash (fileName$, $$CALG_SHA, @hash$)
	PRINT "SHA hash of file "; fileName$; " is : "
	PRINT "hash$ = "; hash$
	PRINT

	PRINT
	a$ = INLINE$ ("Press any key to quit >")


END FUNCTION
'
'
' ###########################
' #####  CreateHash ()  #####
' ###########################
'
' PURPOSE : Perform a hash checksum on a file.
' IN			: fileName$ - file on which to perform hash
'					: algID - hash algorithm ID, the MS RSA Base Provider
'           includes the following hashing algorithms:
'						Constant			Description
'						$$CALG_MD2		MD2
'						$$CALG_MD5		MD5
'						$$CALG_SHA		US DSA Secure Hash Algorithm
'
' OUT			: hash$ - resulting hash string
'
FUNCTION  CreateHash (fileName$, algID, @hash$)

	$BUFSIZE = 1024

	UBYTE rgbFile[]				' buffer that receives file data
	UBYTE rgbHash[]
	UBYTE rgbDigits[]

	IFZ fileName$ THEN RETURN ($$TRUE)

	SELECT CASE algID
		CASE $$CALG_MD2, $$CALG_MD5, $$CALG_SHA :
		CASE ELSE : RETURN ($$TRUE)
	END SELECT

	DIM rgbFile[$BUFSIZE-1]
	DIM rgbDigits[15]

	dwStatus = 0
	bResult = $$FALSE
	hProv = 0
	hHash = 0
	hFile = NULL
	hash$ = ""

	cbRead = 0
	cbHash = 0
	rgbDigits[0] = '0'
	rgbDigits[1] = '1'
	rgbDigits[2] = '2'
	rgbDigits[3] = '3'
	rgbDigits[4] = '4'
	rgbDigits[5] = '5'
	rgbDigits[6] = '6'
	rgbDigits[7] = '7'
	rgbDigits[8] = '8'
	rgbDigits[9] = '9'
	rgbDigits[10] = 'A'
	rgbDigits[11] = 'B'
	rgbDigits[12] = 'C'
	rgbDigits[13] = 'D'
	rgbDigits[14] = 'E'
	rgbDigits[15] = 'F'
'	rgbDigits[] = "0123456789abcdef"

' open existing file for reading
	hFile = CreateFileA (&fileName$, $$GENERIC_READ, $$FILE_SHARE_READ, NULL, $$OPEN_EXISTING, $$FILE_FLAG_SEQUENTIAL_SCAN, NULL)

	IF (hFile = $$INVALID_HANDLE_VALUE) THEN
		dwStatus = GetLastError()
		PRINT "Error opening file "; fileName$; " : Error : ";  dwStatus
		RETURN dwStatus
	END IF

' get handle to the crypto provider
	IF (!CryptAcquireContextA (&hProv, NULL, NULL, $$PROV_RSA_FULL, $$CRYPT_VERIFYCONTEXT)) THEN
		dwStatus = GetLastError()
		PRINT "CryptAcquireContext failed : Error : "; dwStatus
		CloseHandle (hFile)
		RETURN dwStatus
	END IF

	IF (!CryptCreateHash (hProv, algID, 0, 0, &hHash)) THEN
		dwStatus = GetLastError()
		PRINT "CryptAcquireContext failed : Error : "; dwStatus
		CloseHandle(hFile)
		CryptReleaseContext (hProv, 0)
		RETURN dwStatus
	END IF

'	bResult = $$TRUE
	DO 'WHILE bResult
		bResult = ReadFile (hFile, &rgbFile[], $BUFSIZE, &cbRead, NULL)
		IFZ bResult THEN EXIT DO
		IF (cbRead = 0) THEN EXIT DO

		IF (!CryptHashData (hHash, &rgbFile[], cbRead, 0)) THEN
			dwStatus = GetLastError()
			PRINT "CryptHashData failed : Error : "; dwStatus
			CryptReleaseContext (hProv, 0)
			CryptDestroyHash (hHash)
			CloseHandle (hFile)
			RETURN dwStatus
		END IF
	LOOP

	IF (!bResult) THEN
		dwStatus = GetLastError()
		PRINT "ReadFile failed : Error :"; dwStatus
		CryptReleaseContext (hProv, 0)
		CryptDestroyHash (hHash)
		CloseHandle (hFile)
		RETURN dwStatus
	END IF

	hashSize = 0
	cbHash = SIZE (hashSize)

' get hash size required
	IF (CryptGetHashParam (hHash, $$HP_HASHSIZE, &hashSize, &cbHash, 0)) THEN

' size regHash[] array
		DIM rgbHash[hashSize - 1]

' get returned hash value
		IF (CryptGetHashParam (hHash, $$HP_HASHVAL, &rgbHash[], &hashSize, 0)) THEN
			upper = UBOUND (rgbHash[])
			FOR i = 0 TO upper
' reverse bit order
'				PRINT rgbDigits[rgbHash[i] >> 4], rgbDigits[rgbHash[i] & 0xf]
'				PRINT CHR$(rgbDigits[rgbHash[i] >> 4]), CHR$(rgbDigits[rgbHash[i] & 0xf])
				hash$ = hash$ + CHR$(rgbDigits[rgbHash[i] >> 4]) + CHR$(rgbDigits[rgbHash[i] & 0xf])
			NEXT i
		ELSE
			dwStatus = GetLastError()
			PRINT "CryptGetHashParam failed : Error : "; dwStatus
		END IF
	ELSE
		dwStatus = GetLastError()
		PRINT "CryptGetHashParam failed : Error : "; dwStatus
	END IF

	CryptDestroyHash (hHash)
	CryptReleaseContext (hProv, 0)
	CloseHandle (hFile)

	RETURN dwStatus


END FUNCTION
END PROGRAM