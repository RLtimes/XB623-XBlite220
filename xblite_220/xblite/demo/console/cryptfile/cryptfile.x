'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Encrypting and Decrypting a File
' The following example encrypts a data file
' using CryptoAPI functions in advapi32.dll.
' The EncryptFile() function requires an input
' file and an output file. Optionally, a password
' can be used to create the encryption session key.
' If a password is used in the encryption of the
' data, the same password must be used in the
' DecryptFile() function that decrypts the file.

PROGRAM	"cryptfile"
VERSION	"0.0002"
CONSOLE
'
	IMPORT	"xst"
	IMPORT	"kernel32"
	IMPORT	"advapi32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  EncryptFile (sourceFileName$, destFileName$, password$)
DECLARE FUNCTION  Eof (hFile)
DECLARE FUNCTION  DecryptFile (sourceFileName$, destFileName$, password$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

' encrypt file with no password
	s$ = "c:\\xblite\\demo\\console\\cryptfile\\cryptfile.x"
'	s$ = "c:\\autoexec.bat"
	d$ = "encrypt_test.txt"
	EncryptFile (s$, d$, pw$)

' decrypt file
	s$ = "encrypt_test.txt"
	d$ = "decrypt_test.txt"
	pw$ = ""
	DecryptFile (s$, d$, pw$)

' encrypt file with password
	s$ = "c:\\xblite\\demo\\console\\cryptfile\\cryptfile.x"
'	s$ = "c:\\autoexec.bat"
	d$ = "encrypt_pw_test.txt"
	pw$ = "password"
	EncryptFile (s$, d$, pw$)

' decrypt file
	s$ = "encrypt_pw_test.txt"
	d$ = "decrypt_pw_test.txt"
	DecryptFile (s$, d$, pw$)

	PRINT
	a$ = INLINE$ ("Press any key to quit >")


END FUNCTION
'
'
' ############################
' #####  EncryptFile ()  #####
' ############################
'
' PURPOSE	: Encrypt a text file with or without a password
'						using RC4 encryption algorithm.
' IN			: sourceFileName$ - the name of the input file, a plaintext file
'					: destFileName$ - the name of the output file, an encrypted file to be created
'					: password$ - either NULL if a password is not to be used or the string that is the password
'
FUNCTION  EncryptFile (sourceFileName$, destFileName$, password$)

	FUNCADDR	Encrypt (HCRYPTKEY, HCRYPTHASH, XLONG, ULONG, XLONG, XLONG, ULONG)

	HCRYPTKEY hKey, hXchgKey
	HCRYPTHASH hHash
	HCRYPTPROV hProv

	ULONG dwBufferLen

	UBYTE keyBlob[]
	UBYTE buffer[]

	$KEYLENGTH = 0x00800000
	$ENCRYPT_ALGORITHM = $$CALG_RC4		' stream encryption cipher, block size is 1 byte

	IFZ sourceFileName$ THEN RETURN ($$TRUE)
	IFZ destFileName$ THEN RETURN ($$TRUE)

	IFZ password$ THEN
    PRINT "The file will be encrypted without using a password."
	ELSE
		PRINT "The file will be encrypted using a password."
	END IF

'load advapi32.dll library
	hAdvapi = LoadLibraryA (&"advapi32.dll")
	IFZ hAdvapi THEN
		error$ = "LoadLibraryA : advapi32.dll not found"
		GOSUB HandleError
	END IF

'get function address for CryptEncrypt
	Encrypt = GetProcAddress (hAdvapi, &"CryptEncrypt")
	IFZ Encrypt THEN
		error$ = "GetProcAddress : CryptEncrypt Not Found"
		GOSUB HandleError
	END IF

' Open existing source file for reading.
	hSource = CreateFileA (&sourceFileName$, $$GENERIC_READ, $$FILE_SHARE_READ, NULL, $$OPEN_EXISTING, $$FILE_FLAG_SEQUENTIAL_SCAN, NULL)

	IF (hSource = $$INVALID_HANDLE_VALUE) THEN
		error$ = "Error opening file " + sourceFileName$
		errFileDest = $$TRUE
		GOSUB HandleError
	END IF

' Open/create a destination file if it doesn't already exist.
	hDestination = CreateFileA (&destFileName$, $$GENERIC_WRITE, 0, NULL, $$CREATE_NEW, $$FILE_FLAG_SEQUENTIAL_SCAN, NULL)

	IF (hDestination = $$INVALID_HANDLE_VALUE) THEN
		error$ = "Error opening file " + destFileName$
		errFileDest = $$TRUE
		GOSUB HandleError
	END IF

' Get the handle to the default provider.
	IF (!CryptAcquireContextA (&hProv, NULL, &$$MS_ENHANCED_PROV, $$PROV_RSA_FULL, 0)) THEN
		IF (GetLastError () == $$NTE_BAD_KEYSET) THEN
			IF (!CryptAcquireContextA (&hProv, NULL, &$$MS_ENHANCED_PROV, $$PROV_RSA_FULL, $$CRYPT_NEWKEYSET)) THEN
				error$ = "CryptAcquireContext error"
				GOSUB HandleError
			END IF
		ELSE
			error$ = "CryptAcquireContext error"
			GOSUB HandleError
		END IF
	END IF

' Create the session key.

	IFZ password$ THEN

' No password was passed.
' Encrypt the file with a random session key,
' and write the key to a file.

' create a random session key.

		IF (!CryptGenKey (hProv, $ENCRYPT_ALGORITHM, $KEYLENGTH | $$CRYPT_EXPORTABLE, &hKey)) THEN
			error$ = "CryptGenKey error"
			GOSUB HandleError
		END IF

' Get the handle to the encrypter's exchange public key.

		IF (!CryptGetUserKey (hProv, $$AT_KEYEXCHANGE, &hXchgKey)) THEN
			IF (GetLastError () == $$NTE_NO_KEY) THEN
				IF (!CryptGenKey (hProv, $$AT_KEYEXCHANGE, 0, &hXchgKey)) THEN
					error$ = "CryptGenKey error : \nUnable to create exchange public key"
					GOSUB HandleError
				END IF
			ELSE
				error$ = "CryptGetUserKey error : \nUser public key is not available and may not exist"
				GOSUB HandleError
			END IF
		END IF

' Determine size of the key BLOB, and allocate memory.

		IF (!CryptExportKey (hKey, hXchgKey, $$SIMPLEBLOB, 0, NULL, &dwKeyBlobLen)) THEN
			error$ = "CryptExportKey error : \nError computing BLOB length"
			GOSUB HandleError
		END IF

		IFZ dwKeyBlobLen THEN
			error$ = "CryptExportKey error : BLOB length zero"
			GOSUB HandleError
		END IF

		DIM keyBlob[dwKeyBlobLen-1]
		pbKeyBlob = &keyBlob[]

' Encrypt and export the session key into a simple key BLOB.

		IF (!CryptExportKey (hKey, hXchgKey, $$SIMPLEBLOB, 0, pbKeyBlob, &dwKeyBlobLen)) THEN
			error$ = "CryptExportKey error"
			GOSUB HandleError
		END IF

' Release the key exchange key handle.

		IF (hXchgKey) THEN
			IF (!CryptDestroyKey (hXchgKey)) THEN
				error$ = "CryptDestroyKey error"
				GOSUB HandleError
			END IF
			hXchgKey = 0
		END IF

' Write the size of the key BLOB to a destination file.

		IF (!WriteFile (hDestination, &dwKeyBlobLen, SIZE (XLONG), &written, 0)) THEN
			error$ = "WriteFile error : writing BLOB length to header"
			GOSUB HandleError
		END IF

' Write the key BLOB to a destination file.

		IF (!WriteFile (hDestination, pbKeyBlob, dwKeyBlobLen, &written, 0)) THEN
			error$ = "WriteFile error : writing BLOB header"
			GOSUB HandleError
		END IF

' Free memory.
		DIM keyBlob[]

	ELSE

' the file will be encrypted with a session key derived from a password.
' the session key will be recreated when the file is decrypted
' only if the password used to create the key is available.

' Create a hash object.

		IF (!CryptCreateHash (hProv, $$CALG_MD5, 0, 0, &hHash)) THEN
			error$ = "CryptCreateHash error"
			GOSUB HandleError
		END IF

' Hash the password.

		IF (!CryptHashData (hHash, &password$, LEN(password$), 0)) THEN
			error$ = "CryptHashData error"
			GOSUB HandleError
		END IF

' Derive a session key from the password hash object.

		IF (!CryptDeriveKey (hProv, $ENCRYPT_ALGORITHM, hHash, $KEYLENGTH, &hKey)) THEN
			error$ = "CryptDeriveKey error"
			GOSUB HandleError
		END IF

' Destroy hash object.

		IF (hHash) THEN
			IF (!CryptDestroyHash (hHash)) THEN
				error$ = "CryptDestroyHash error"
				GOSUB HandleError
			END IF
		END IF
		hHash = 0

	END IF

' The session key is now ready. If it is not a key derived from a
' password, the session key encrypted with the encrypter's private
' key has been written to the destination file.

' for stream ciphers, buffer size can be equal to the block length
	dwBlockLen = 1024
	dwBufferLen = dwBlockLen

' allocate memory.
	DIM buffer[dwBufferLen - 1]
	pbBuffer = &buffer[]

' In a do loop, encrypt the source file, and write to the source file.

	DO

' Read up to dwBlockLen bytes from the source file.

		IF (!ReadFile (hSource, pbBuffer, dwBlockLen, &dwCount, NULL)) THEN
			error$ = "ReadFile Error"
			GOSUB HandleError
		END IF

		eof = Eof (hSource)

' Encrypt data.
' note: CrypteEncrypt does weird things with memory and crashes program.
'       However, it does work if called by a computed function address

'		ret = CryptEncrypt (hKey, 0, eof, 0, pbBuffer, &dwCount, dwBufferLen)

		ret = @Encrypt (hKey, 0, eof, 0, pbBuffer, &dwCount, dwBufferLen)

		IFZ ret THEN
			error$ = "CryptEncrypt error"
			GOSUB HandleError
		END IF

' Write data to the destination file.
		IF (!WriteFile (hDestination, pbBuffer, dwCount, &written, 0)) THEN
			error$ = "WriteFile error : writing to encrypted file"
			GOSUB HandleError
		END IF

	LOOP UNTIL eof

' End the do loop when the last block of the source file has been
' read, encrypted, and written to the destination file.

' Close files.

	IF (hSource) THEN
		IF (!CloseHandle (hSource)) THEN
			error$ = "CloseHandle error : closing source file"
			GOSUB HandleError
		END IF
	END IF

	IF (hDestination) THEN
		IF (!CloseHandle (hDestination)) THEN
			error$ = "CloseHandle error : closing destination file"
			GOSUB HandleError
		END IF
	END IF

' Free memory.

	DIM buffer[]

' Destroy the session key.

	IF (hKey) THEN
		IF (!CryptDestroyKey (hKey)) THEN
			error$ = "CryptDestroyKey error"
			GOSUB HandleError
		END IF
	END IF

' Release the provider handle.

	IF (hProv) THEN
		IF (!CryptReleaseContext (hProv, 0)) THEN
			error$ = "CryptReleaseContext error"
			GOSUB HandleError
		END IF
	END IF

'free the dll
	IF hAdvapi THEN FreeLibrary (hAdvapi)

	RETURN

' This example uses the SUB HandleError, a simple error
' handling subroutine to print an error message
' and then return from function.
' ***** HandleError *****
SUB HandleError
	PRINT "An error occurred in EncryptFile()"
	PRINT error$
	sysError = GetLastError()
	XstSystemErrorNumberToName (sysError, @sysError$)
  PRINT "Error number :"; sysError; " : "; sysError$

	IF hSource 			THEN CloseHandle (hSource)
	IF hDestination THEN CloseHandle (hDestination)
	IFZ errFileDest THEN
		IF hDestination THEN DeleteFileA (&destFileName$)
	END IF
	IF hKey 				THEN CryptDestroyKey(hKey)
	IF hXchgKey 		THEN CryptDestroyKey (hXchgKey)
	IF hHash				THEN CryptDestroyHash (hHash)
	IF hProv 	THEN CryptReleaseContext (hProv, 0)
	IF hAdvapi THEN FreeLibrary (hAdvapi)

	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ####################
' #####  Eof ()  #####
' ####################

' PURPOSE : return $$TRUE (-1) if the current file pointer
'						is beyond end of file or $$FALSE (0) is not.
' IN			: hFile - valid handle to a file
' NOTE		: an error will return a value of 1, so if needed,
'						check the return value accordingly

FUNCTION  Eof (hFile)

	IFZ hFile THEN RETURN (1)

' get the current value of the file pointer
	cfp = SetFilePointer (hFile, 0, 0, $$FILE_CURRENT)
	IF (cfp = -1) THEN RETURN (1)

' get the end-of-file pointer
	efp = SetFilePointer (hFile, 0, 0, $$FILE_END)
	IF (efp = -1) THEN RETURN (1)

' set new file pointer back to original place
	fp = SetFilePointer (hFile, cfp, 0, $$FILE_BEGIN)
	IF (fp = -1) THEN RETURN (1)

'PRINT "Eof : cfp="; cfp; " efp="; efp; " fp="; fp

	IF (cfp >= efp) THEN RETURN ($$TRUE) ELSE RETURN ($$FALSE)

END FUNCTION
'
'
' ############################
' #####  DecryptFile ()  #####
' ############################
'
' PURPOSE	: Decrypt an encrypted text file. If the file was encrypted with
'						a password, then it must be decrypted with the same password.
' IN			: sourceFileName$ - the name of the encrypted file
'					: destFileName$ - the name of the output file
'					: password$ - either NULL if a password is not required or password string
'
FUNCTION  DecryptFile (sourceFileName$, destFileName$, password$)

	FUNCADDR	Decrypt (HCRYPTKEY, HCRYPTHASH, XLONG, ULONG, XLONG, XLONG)

	HCRYPTKEY hKey
	HCRYPTHASH hHash
	HCRYPTPROV hProv

	UBYTE keyBlob[]
	UBYTE buffer[]

	$KEYLENGTH = 0x00800000
	$ENCRYPT_ALGORITHM = $$CALG_RC4		' stream encryption cipher, block size is 1 byte

	IFZ sourceFileName$ THEN RETURN ($$TRUE)
	IFZ destFileName$ THEN RETURN ($$TRUE)

	IFZ password$ THEN
    PRINT "The file will be decrypted without using a password."
	ELSE
    PRINT "The file will be decrypted using a password."
	END IF

'load advapi32.dll library
	hAdvapi = LoadLibraryA (&"advapi32.dll")
	IFZ hAdvapi THEN
		error$ = "LoadLibraryA : advapi32.dll not found"
		GOSUB HandleError
	END IF

'get function address for CryptDecrypt
	Decrypt = GetProcAddress (hAdvapi, &"CryptDecrypt")
	IFZ Decrypt THEN
		error$ = "GetProcAddress : CryptDecrypt Not Found"
		GOSUB HandleError
	END IF

' Open existing source file to decrypt for reading
	hSource = CreateFileA (&sourceFileName$, $$GENERIC_READ, $$FILE_SHARE_READ, NULL, $$OPEN_EXISTING, $$FILE_FLAG_SEQUENTIAL_SCAN, NULL)

	IF (hSource = $$INVALID_HANDLE_VALUE) THEN
		error$ = "Error opening file " + sourceFileName$
		errFileDest = $$TRUE
		GOSUB HandleError
	END IF

' Open destination file
	hDestination = CreateFileA (&destFileName$, $$GENERIC_WRITE, 0, NULL, $$CREATE_NEW, $$FILE_FLAG_SEQUENTIAL_SCAN, NULL)

	IF (hDestination = $$INVALID_HANDLE_VALUE) THEN
		error$ = "Error opening file " + destFileName$
		errFileDest = $$TRUE
		GOSUB HandleError
	END IF

' Get the handle to the default provider
	IF (!CryptAcquireContextA (&hProv, NULL, &$$MS_ENHANCED_PROV, $$PROV_RSA_FULL, 0)) THEN
		IF (GetLastError () == $$NTE_BAD_KEYSET) THEN
			IF (!CryptAcquireContextA (&hProv, NULL, &$$MS_ENHANCED_PROV, $$PROV_RSA_FULL, $$CRYPT_NEWKEYSET)) THEN
				error$ = "CryptAcquireContext error"
				GOSUB HandleError
			END IF
		ELSE
			error$ = "CryptAcquireContext error"
			GOSUB HandleError
		END IF
	END IF

'	Check for the existence of a password.

	IFZ password$ THEN

' Decrypt the file with the saved session key.

' Read key BLOB length from source file, and allocate memory.
		ret = ReadFile (hSource, &dwKeyBlobLen, SIZE (XLONG), &dwCount, NULL)
		IF (!ret || Eof (hSource)) THEN
			error$ = "ReadFile error : reading header key BLOB length"
			GOSUB HandleError
		END IF

' note: for this particular encrypt/decrypt pair, the BLOB length is 76
' but not always!!!

'		IF (!dwKeyBlobLen || (dwKeyBlobLen != 76)) THEN

		IF (!dwKeyBlobLen) THEN
			error$ = "Key BLOB length error"
			GOSUB HandleError
		END IF

		DIM keyBlob[dwKeyBlobLen-1]
		pbKeyBlob = &keyBlob[]

' Read key BLOB from source file.
		ret = ReadFile (hSource, pbKeyBlob, dwKeyBlobLen, &dwCount, NULL)
		IF (!ret || Eof (hSource)) THEN
			error$ = "ReadFile error : reading header key BLOB"
			GOSUB HandleError
		END IF

' Import key BLOB into CSP.
		IF (!CryptImportKey (hProv, pbKeyBlob, dwKeyBlobLen, 0, 0, &hKey)) THEN
			error$ = "CryptImportKey error"
			GOSUB HandleError
		END IF

	ELSE

' Decrypt the file with a session key derived from a password.

' Create a hash object.
		IF (!CryptCreateHash (hProv, $$CALG_MD5, 0, 0, &hHash)) THEN
			error$ = "CryptCreateHash error"
			GOSUB HandleError
		END IF

' Hash in the password data.
		IF (!CryptHashData (hHash, &password$, LEN (password$), 0)) THEN
			error$ = "CryptHashData error"
			GOSUB HandleError
		END IF

' Derive a session key from the hash object.
		IF (!CryptDeriveKey (hProv, $ENCRYPT_ALGORITHM, hHash, $KEYLENGTH, &hKey)) THEN
			error$ = "CryptDeriveKey error"
			GOSUB HandleError
		END IF

' Destroy the hash object.

		IF (!CryptDestroyHash (hHash)) THEN
			error$ = "CryptDeriveKey error"
			GOSUB HandleError
		END IF

	END IF

' The decryption key is now available, either having been imported
' from a BLOB read in from the source file or having been created
' using the password. This point in the program is not reached if
' the decryption key is not available.

' for stream ciphers, buffer size can be equal to the block length
	dwBlockLen = 1024

' Allocate buffer memory.
	DIM buffer[dwBlockLen - 1]
	pbBuffer = &buffer[]

' Decrypt source file, and write to destination file.

	DO

' Read up to dwBlockLen bytes from source file.

		bResult = ReadFile (hSource, pbBuffer, dwBlockLen, &dwCount, NULL)
		IFZ bResult THEN
			error$ = "ReadFile error : reading from encrypted file"
			GOSUB HandleError
		END IF

		eof = Eof (hSource)

' Decrypt data.
'		IF (!CryptDecrypt (hKey, 0, eof, 0, pbBuffer, &dwCount)) THEN

' Note: computed function address for CryptDecrypt works

		IF (!@Decrypt (hKey, 0, eof, 0, pbBuffer, &dwCount)) THEN
			error$ = "CryptDecrypt error"
			GOSUB HandleError
		END IF

' Write data to destination file.
		IF (!WriteFile (hDestination, pbBuffer, dwCount, &written, 0)) THEN
			error$ = "WriteFile error : writing to decrypted file"
			GOSUB HandleError
		END IF

	LOOP UNTIL eof

' Close files.
	IF (hSource) THEN
		IF (!CloseHandle (hSource)) THEN
			error$ = "CloseHandle error : closing source file"
			GOSUB HandleError
		END IF
	END IF

	IF (hDestination) THEN
		IF (!CloseHandle (hDestination)) THEN
			error$ = "CloseHandle error : closing destination file"
			GOSUB HandleError
		END IF
	END IF

' Free memory.

	DIM keyBlob[]
	DIM buffer[]

' Destroy the session key.

	IF (hKey) THEN
		IF (!CryptDestroyKey (hKey)) THEN
			error$ = "CryptDestroyKey error"
			GOSUB HandleError
		END IF
	END IF

' Release the provider handle.

	IF (hProv) THEN
		IF (!CryptReleaseContext (hProv, 0)) THEN
			error$ = "CryptReleaseContext error"
			GOSUB HandleError
		END IF
	END IF

	RETURN

' This example uses the SUB HandleError, a simple error
' handling subroutine to print an error message
' and then return from function.
' ***** HandleError *****
SUB HandleError
	PRINT "An error occurred in DecryptFile()"
	PRINT error$
	sysError = GetLastError()
	XstSystemErrorNumberToName (sysError, @sysError$)
  PRINT "Error number :"; sysError; " : "; sysError$

	IF hSource 			THEN CloseHandle (hSource)
	IF hDestination THEN CloseHandle (hDestination)
	IFZ errFileDest THEN
		IF hDestination THEN DeleteFileA (&destFileName$)
	END IF
	IF hKey 				THEN CryptDestroyKey(hKey)
	IF hHash				THEN CryptDestroyHash (hHash)
	IF hProv 	THEN CryptReleaseContext (hProv, 0)
	IF hAdvapi THEN FreeLibrary (hAdvapi)

	RETURN ($$TRUE)
END SUB


END FUNCTION
END PROGRAM
