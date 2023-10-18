'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Program displays a dialog box which gives
' various OS information.
' Written by Tim Hext-Stephens - 2003
'
PROGRAM "info"
VERSION "1.42"
'
' Uncomment this line to include xb.dll into executable
'MAKEFILE "xexe.xxx"
'
'
IMPORT "xst"
'IMPORT "xio"
'IMPORT "xsx.o"			' include xsx.o library object into executable
IMPORT "xsx"
IMPORT "gdi32"
IMPORT "user32"
IMPORT "shell32"
IMPORT "kernel32"
IMPORT "advapi32"
IMPORT "comctl32"
IMPORT "version"
'
'
TYPE WSADATA
	USHORT     .wVersion
	USHORT     .wHighVersion
	STRING*257 .szDescription
	STRING*129 .szSystemStatus
	USHORT     .iMaxSockets
	USHORT     .iMaxUdpDg
	XLONG      .lpVendorInfo
END TYPE

TYPE OSINFO
	STRING*32		.Name
	STRING*8		.Version
	STRING*16		.Platform
	STRING*128	.WindowsDir
	STRING*128	.SystemDir
	STRING*12		.TotalMem
	STRING*16		.NetPresent
	STRING*32		.INetBrowser
	STRING*128	.BrowserDesc
	STRING*16		.VerBrowser
	STRING*32		.AcroRdrExe
	STRING*128	.AcroRdrDesc
	STRING*16		.VerAcroRdr
	STRING*24		.HostFile
	STRING*4		.MachineOK
END TYPE
'
'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION PreChecks ()
DECLARE FUNCTION STRING GetCmdLineArg ()
DECLARE FUNCTION InitGUI ()
DECLARE FUNCTION CreateWindows ()
DECLARE FUNCTION DlgProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION GetOSInfo ()
DECLARE FUNCTION DisplayProgVersion ()
DECLARE FUNCTION STRING GetWinDir ()
DECLARE FUNCTION STRING GetSysDir ()
DECLARE FUNCTION CheckedAlready ()
DECLARE FUNCTION WriteRegEntry ()
DECLARE FUNCTION AddKeyVal (standard, subKey$, keyName$, content$)
DECLARE FUNCTION RemoveRegEntry ()
DECLARE FUNCTION NetInstalled ()
DECLARE FUNCTION STRING CheckHost (host$)
DECLARE FUNCTION STRING IP2Text (IP$)
DECLARE FUNCTION SockInit ()
DECLARE FUNCTION CleanSocks ()
DECLARE FUNCTION IsIPInstalled ()
DECLARE FUNCTION InstalledNetType ()
DECLARE FUNCTION STRING DecodeFlags (flags)
DECLARE FUNCTION STRING GetAssociatedExe (sExt$)
DECLARE FUNCTION STRING XtractFileName (fname$)
DECLARE FUNCTION GetInstalledRAM ()
DECLARE FUNCTION STRING GetVersionInfo (sFile$)
DECLARE FUNCTION STRING GetProcessorInfo ()
DECLARE FUNCTION RunFromCD ()
DECLARE FUNCTION STRING GetCDRomDrives ()
DECLARE FUNCTION DoChecks ()
'
'
$$INTERNET_CONNECTION_MODEM       	= 0x1
$$INTERNET_CONNECTION_LAN         	= 0x2
$$INTERNET_CONNECTION_PROXY       	= 0x4
$$INTERNET_CONNECTION_MODEM_BUSY  	= 0x8
$$INTERNET_RAS_INSTALLED						= 0x10
$$INTERNET_CONNECTION_OFFLINE				= 0x20
$$INTERNET_CONNECTION_CONFIGURED		= 0x40
$$SM_NETWORK = 63
'
'
'Control IDs
$$OSNAME 			= 201
$$OSVERSION 	= 202
$$OSPLATFORM 	= 203
$$INSTALLED 	= 215
$$LOCALHOST 	= 217
$$WINDIR 			= 204
$$SYSDIR 			= 205
$$NETTYPE			= 216
$$BROWSEREXE 	= 208
$$ACRORDR 		= 211
$$NOTES				= 214
$$VERBROWSER 	= 210
$$VERACRORDR 	= 213
$$TOTALMEM 		= 207
$$CPUID 			= 206
$$BROWSERDESC = 209
$$ACRORDRDESC = 212
'
'
FUNCTION Entry ()

	STATIC entry
	SHARED errflag

' Initialize Xsx() library if imported as object library
' using IMPORT "xsx.o"
	Xsx()

	IF entry THEN RETURN
	entry = $$TRUE

' Check to see if run from CD-ROM or there are command line args
' Uncomment this to run PreChecks()
'	ok = PreChecks ()

' Only display test dialog then exit
' Comment this line out if running PreChecks()
	ok = 2

		SELECT CASE ok
			CASE -1
			' Exit program
				RETURN
			CASE 0
			' All prechecks passed so launch CD
				' Code goes here to launch exe from CD
				RETURN
			CASE 1
			' Display test dialog then launch CD exe if all tests pass
				r = DoChecks ()
				InitGUI ()
				CreateWindows ()
					IFZ r THEN
						' Code goes here to launch exe from CD
					END IF
			CASE 2
			' Only display test dialog then exit
				DoChecks ()
				InitGUI ()
				CreateWindows ()
		END SELECT

END FUNCTION
'
'
' ************************
' ***** PreChecks () *****
' ************************
'
FUNCTION PreChecks ()

		IFZ RunFromCD () THEN
			MessageBoxA (0, &"This program can only be run\nfrom CD", &"Diagnostic Tests", $$MB_OK + $$MB_ICONHAND)
			'RETURN -1
		END IF

	arg$ = GetCmdLineArg ()
		SELECT CASE arg$
			CASE "/?"
			' Display help screen
				msg$ = "This program performs a basic compatibility test.\n"
				msg$ = msg$ + "If ALL tests are successful, an entry is written to your\n"
				msg$ = msg$ + "computer's Windows registry and the Amber CD is launched.\n\n"
				msg$ = msg$ + "If any of the tests fail, a report detailing the findings is\n"
				msg$ = msg$ + "displayed.\n\n"

				MessageBoxA ( 0, &msg$, &"Diagnostic Tests", $$MB_OK + $$MB_ICONINFORMATION)
				RETURN -1
			CASE "/V"
			' Display version information
				DisplayProgVersion ()
				RETURN -1
			CASE "/D"
			' Delete registry entry
				RemoveRegEntry ()
				RETURN -1
			CASE "/R"
				RETURN 2
		END SELECT

		IFZ CheckedAlready () THEN
				msg$ = "This program performs a basic compatibility test.\n"
				msg$ = msg$ + "If ALL tests are successful, an entry is written to your\n"
				msg$ = msg$ + "computer's Windows registry and the CD is launched.\n\n"
				msg$ = msg$ + "If any of the tests fail, a report detailing the findings is\n"
				msg$ = msg$ + "displayed.\n\n"
				msg$ = msg$ + "Please click OK to perform the test or Cancel to exit without\n"
				msg$ = msg$ + "running any tests."
				ret = MessageBoxA ( 0, &msg$, &"Diagnostic Tests", $$MB_OKCANCEL + $$MB_ICONEXCLAMATION)
				SELECT CASE ret
					CASE $$IDOK
						' OK button was pressed
						RETURN 1
					CASE $$IDCANCEL
						' Cancel button was pressed
						RETURN -1
				END SELECT
		END IF

	RETURN 0

'
END FUNCTION
'
'
' ****************************
' ***** GetCmdLineArg () *****
' ****************************
'
FUNCTION STRING GetCmdLineArg ()

	XstGetCommandLineArguments(@argCount, @argv$[])

		IF argCount > 1 THEN
			SELECT CASE UCASE$(argv$[1])
				CASE "/REPORT", "/R"
					RETURN "/R"
				CASE "/DELETE", "/D"
					RETURN "/D"
				CASE "/VERSION", "/V"
					RETURN "/V"
				CASE "/HELP", "/H", "/?"
					RETURN "/?"
			END SELECT
		END IF

END FUNCTION
'
'
' ************************
' *****  InitGui ()  *****
' ************************
'
FUNCTION  InitGUI ()

	SHARED hInst

	hInst = GetModuleHandleA (0) 	' get current instance handle
	IFZ hInst THEN QUIT(0)

END FUNCTION
'
'
' *************************
' ***** CreateWindows *****
' *************************
'
FUNCTION CreateWindows ()
' Create main diagnostic window

	SHARED hInst

	RETURN DialogBoxParamA (hInst, 100, 0, &DlgProc(), 0)

END FUNCTION
'
'
' ************************
' *****  DlgProc ()  *****
' ************************
'
FUNCTION  DlgProc (hwndDlg, msg, wParam, lParam)

SHARED OSINFO pcinfo
bkColor = GetSysColor ($$COLOR_BTNFACE)

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			XstCenterWindow (hwndDlg)
			SetDlgItemTextA (hwndDlg, $$OSNAME,      &pcinfo.Name)
			SetDlgItemTextA (hwndDlg, $$OSVERSION,   &pcinfo.Version)
			SetDlgItemTextA (hwndDlg, $$OSPLATFORM,  &pcinfo.Platform)
			SetDlgItemTextA (hwndDlg, $$WINDIR,      &pcinfo.WindowsDir)
			SetDlgItemTextA (hwndDlg, $$SYSDIR,      &pcinfo.SystemDir)
			SetDlgItemTextA (hwndDlg, $$BROWSEREXE,  &pcinfo.INetBrowser)
			SetDlgItemTextA (hwndDlg, $$BROWSERDESC, &pcinfo.BrowserDesc)
			SetDlgItemTextA (hwndDlg, $$VERBROWSER,  &pcinfo.VerBrowser)
			SetDlgItemTextA (hwndDlg, $$ACRORDR,     &pcinfo.AcroRdrExe)
			SetDlgItemTextA (hwndDlg, $$ACRORDRDESC, &pcinfo.AcroRdrDesc)
			SetDlgItemTextA (hwndDlg, $$VERACRORDR,  &pcinfo.VerAcroRdr)
			r$ = GetProcessorInfo ()
			SetDlgItemTextA (hwndDlg, $$CPUID,       &r$)
			SetDlgItemTextA (hwndDlg, $$TOTALMEM,    &pcinfo.TotalMem)
			SetDlgItemTextA (hwndDlg, $$INSTALLED,   &pcinfo.NetPresent)
				IF NetInstalled ()
					r$ = DecodeFlags (InstalledNetType ())
				ELSE
					r$ = "No"
				END IF
			SetDlgItemTextA (hwndDlg, $$NETTYPE,     &r$)
			SetDlgItemTextA (hwndDlg, $$LOCALHOST,   &pcinfo.HostFile)
			r$ = "CD-ROM Drive(s) = " + GetCDRomDrives ()
			SetDlgItemTextA (hwndDlg, $$NOTES,       &r$)

		CASE $$WM_CTLCOLORDLG :
			hdcDlg = wParam
			hwndDlg = lParam
			RETURN SetColor (0, bkColor, wParam, lParam)

		CASE $$WM_CTLCOLORBTN :
			hdcDlg = wParam
			hwndDlg = lParam
			RETURN SetColor (0, bkColor, wParam, lParam)

		CASE $$WM_CTLCOLORSTATIC :
			hdcDlg = wParam
			hwndDlg = lParam
			RETURN SetColor (0, bkColor, wParam, lParam)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD(wParam)
			ID         = LOWORD(wParam)
			hwndCtl    = lParam

				SELECT CASE notifyCode
					CASE $$BN_CLICKED :
						EndDialog (hwndDlg, ID)
						RETURN ID
				END SELECT

		CASE ELSE : RETURN ($$FALSE)

	END SELECT

	RETURN ($$TRUE)

END FUNCTION
'
'
' *************************
' *****  SetColor ()  *****
' *************************
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
	SHARED hNewBrush
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush
END FUNCTION
'
'
' ************************
' ***** GetOSInfo () *****
' ************************
'
FUNCTION GetOSInfo ()

	SHARED OSINFO pcinfo

		IFZ XstGetOSName (@os$) THEN
			pcinfo.Name = os$
				IFZ XstGetOSVersion (@major, @minor, @platformId, @version$, @platform$) THEN
					pcinfo.Version = STRING$(major) + "." + STRING$(minor)
					pcinfo.Platform = platform$
				END IF
			pcinfo.WindowsDir = GetWinDir ()
			pcinfo.SystemDir = GetSysDir ()
			RETURN 0
		END IF

	RETURN 1

END FUNCTION
'
'
' *********************************
' ***** DisplayProgVersion () *****
' *********************************
'
FUNCTION DisplayProgVersion ()

	msg$ = "Diagnostic Tests\nVersion : " + VERSION$(0)

	MessageBoxA ( 0, &msg$, &"CD Diagnostic Tests", $$MB_OK + $$MB_ICONINFORMATION)

END FUNCTION
'
'
' ************************
' ***** GetWinDir () *****
' ************************
'
FUNCTION STRING GetWinDir ()

	buf$ = CHR$(32,255)
	ret = GetWindowsDirectoryA (&buf$, SIZE(buf$))
	buf$ = LEFT$(buf$, ret)

	RETURN buf$

END FUNCTION
'
'
' ************************
' ***** GetSysDir () *****
' ************************
'
FUNCTION STRING GetSysDir ()

	buf$ = CHR$(32,255)
	ret = GetSystemDirectoryA (&buf$, SIZE(buf$))
	buf$ = LEFT$(buf$, ret)

	RETURN buf$

END FUNCTION
'
'
' *****************************
' ***** CheckedAlready () *****
' *****************************
'
FUNCTION CheckedAlready ()

	subkey$ = "Software\\Program"

		IFZ RegOpenKeyExA ($$HKEY_CURRENT_USER, &subkey$, 0, $$KEY_READ, &hKey) THEN RETURN 1

END FUNCTION
'
'
' ******************************
' ***** WriteRegEntry () *****
' ******************************
'
FUNCTION WriteRegEntry ()

	AddKeyVal ($$HKEY_CURRENT_USER, "Software\\Program", "Default", "Done")

END FUNCTION
'
'
' ************************
' ***** AddKeyVal () *****
' ************************
'
FUNCTION AddKeyVal (standard, subKey$, keyName$, content$)

	IFZ RegCreateKeyExA (standard, &subKey$, 0, &class$, 0, $$KEY_WRITE, NULL, &hKey, &neworused) THEN
		x = RegSetValueExA (hKey, &keyName$, 0, $$REG_SZ, &content$, SIZE(content$))
	END IF

END FUNCTION
'
'
' *******************************
' ***** RemoveRegEntry () *****
' *******************************
'
FUNCTION RemoveRegEntry ()

	subKey$ = "Software\\Program"

	RegDeleteKeyA ($$HKEY_CURRENT_USER, &subKey$)

END FUNCTION
'
'
' ***************************
' ***** NetInstalled () *****
' ***************************
'
FUNCTION NetInstalled ()

	RETURN GetSystemMetrics ($$SM_NETWORK) AND 1

END FUNCTION
'
'
' *****************************
' ***** CheckHost () *****
' *****************************
'
FUNCTION STRING CheckHost (host$)

	FUNCADDR GetHost (XLONG)

	IFZ SockInit () THEN
		hWinsockDll = LoadLibraryA (&"wsock32.dll")
			IFZ hWinsockDll THEN
				FreeLibrary (hWinsockDll)
				RETURN "WSOCK ERROR"
			END IF
		GetHost = GetProcAddress (hWinsockDll, &"gethostbyname")
			IFZ GetHost THEN
				FreeLibrary (hWinsockDll)
				RETURN "FUNC ERROR"
			END IF
		hptr = @GetHost (&host$)
		IF hptr THEN
			ip$ = CHR$(32, 4)
			nptr = hptr
			aptr = hptr + 12

			XstCopyMemory (aptr, &aptr, 4)
			XstCopyMemory (aptr, &iptr, 4)
			XstCopyMemory (iptr, &ip$, 4)

			ip$ = IP2Text (ip$)
			FreeLibrary (hWinsockDll)
			RETURN ip$
		ELSE
			FreeLibrary (hWinsockDll)
			RETURN "DNS ERROR"
		END IF
	END IF
	RETURN "SOCKET ERROR"
END FUNCTION
'
'
' **********************
' ***** IP2Text () *****
' **********************
'
FUNCTION STRING IP2Text (IP$)

   i$ = STRING$(IP${0}) + "." + STRING$(IP${1}) + "." + STRING$(IP${2}) + "." + STRING$(IP${3})

   RETURN i$

END FUNCTION
'
'
' ***********************
' ***** SockInit () *****
' ***********************
'
FUNCTION SockInit ()

	FUNCADDR WSAStart (XLONG, XLONG)

	WSADATA	wsd
	WS_VERSION_REQD = 0x101

		hWinsockDll = LoadLibraryA (&"wsock32.dll")
			IFZ hWinsockDll THEN RETURN 1
		WSAStart = GetProcAddress (hWinsockDll, &"WSAStartup")
			IFZ WSAStart THEN
				FreeLibrary (hWinsockDll)
				RETURN 1
			END IF
			IFZ @WSAStart (WS_VERSION_REQD, &wsd) THEN
				FreeLibrary (hWinsockDll)
				RETURN 0
			ELSE
				FreeLibrary (hWinsockDll)
			END IF

		RETURN 1

END FUNCTION
'
'
' *************************
' ***** CleanSocks () *****
' *************************
'
FUNCTION CleanSocks ()

  FUNCADDR CleanUp ()

  	hWinsockDll = LoadLibraryA (&"wsock32.dll")
  		IFZ hWinsockDll THEN RETURN 1
  	CleanUp = GetProcAddress (hWinsockDll, &"WSACleanup")
  		IFZ CleanUp THEN
  			FreeLibrary (hWinsockDll)
  			RETURN 2
  		END IF
  		IFZ @CleanUp () THEN
				FreeLibrary (hWinsockDll)
		  RETURN 0
		  ELSE
		  FreeLibrary (hWinsockDll)
		  RETURN 3
		  END IF

END FUNCTION
'
'
' ***************************
' **** IsIPInstalled () *****
' ***************************
'
FUNCTION IsIPInstalled ()

	ipaddr$ = CheckHost (@"localhost")
	CleanSocks ()

	IF INSTR(ipaddr$, ".") THEN
		' Resolved localhost to address OK so IP must be installed

		RETURN 1

	ELSE

		RETURN 0

	END IF

END FUNCTION
'
'
' *******************************
' ***** InstalledNetType () *****
' *******************************
'
FUNCTION InstalledNetType ()

	FUNCADDR InetState (XLONG, XLONG)

	hWininetDll = LoadLibraryA (&"wininet.dll")
	  IFZ hWininetDll THEN RETURN 0
	InetState = GetProcAddress (hWininetDll, &"InternetGetConnectedState")
	  IFZ InetState THEN
	    FreeLibrary (hWininetDll)
	    RETURN 0
	  ELSE
	      IFZ @InetState (&dwFlags, 0)
					FreeLibrary (hWininetDll)
					RETURN 0
				END IF
			FreeLibrary (hWininetDll)
			RETURN dwFlags
		END IF

END FUNCTION
'
'
' **************************
' ***** DecodeFlags () *****
' **************************
'
FUNCTION STRING DecodeFlags(flags)

	flag$ = "MDM ,LAN ,PRX ,BSY ,RAS ,OFF ,NET "
	XstParseStringToStringArray(flag$, ",", @flag$[])
	m$ = ""
	FOR x = 0 TO 6
		IF flags AND (2**x) THEN
			m$ = m$ + flag$[x]
		END IF
	NEXT

	RETURN m$

END FUNCTION
'
'
' ************************************
' ***** GetAssociatedExe (sExt$) *****
' ************************************
'
FUNCTION STRING GetAssociatedExe (sExt$)

	SHARED errflag

		IFZ XstGetEnvironmentVariable ("TEMP", @tmpdir$) THEN
			AssociatedExe$ = CHR$(32, 255)
			sFileName$ = tmpdir$ + "\\temp." + sExt$
			sWrite$ = "Test Text"
			ofile = OPEN(sFileName$, $$WRNEW)
				IF ofile < 3 THEN errflag = 1: RETURN "!ERROR! NOT CREATED"
			WRITE [ofile], sWrite$
			CLOSE (ofile)
			r = FindExecutableA (&sFileName$, &tmpdir$, &AssociatedExe$)
			AssociatedExe$ = TRIM$(AssociatedExe$)

			XstDeleteFile(sFileName$)
				IF r <= 32 || (AssociatedExe$ = "") THEN errflag = 1: RETURN ""
		END IF

	RETURN AssociatedExe$

END FUNCTION
'
'
' ***********************************
' ***** XtractFileName (fname$) *****
' ***********************************
'
FUNCTION STRING XtractFileName (fname$)

	XstGetPathComponents(fname$, @path$, @drive$, @dir$, @filename$, @attributes)

	RETURN filename$

END FUNCTION
'
'
' ******************************
' ***** GetInstalledRAM () *****
' ******************************
'
FUNCTION GetInstalledRAM ()

	MEMORYSTATUS memstat

		memstat.dwLength = SIZE(memstat)
		GlobalMemoryStatus (&memstat)
		memstat.dwTotalPhys = INT(memstat.dwTotalPhys / (1043321) + .5)

	RETURN memstat.dwTotalPhys

END FUNCTION
'
'
' ***********************************
' ***** GetVersionInfo (sFile$) *****
' ***********************************
'
FUNCTION STRING GetVersionInfo (sFile$)
' Returns file version and description as | delimited string

	VS_FIXEDFILEINFO verinf
	SHARED errflag

	DIM vinfo@[]

	ret$ = "No Version Info"
	bufsize =  GetFileVersionInfoSizeA (&sFile$, &vHnd)

		IF bufsize > 0 THEN

			REDIM vinfo@[bufsize]

				IF GetFileVersionInfoA (&sFile$, vHnd, bufsize, &vinfo@[0]) THEN
						IF VerQueryValueA (&vinfo@[0], &"\\VarFileInfo\\Translation", &vptr, &vlen) THEN
							buf$ = CHR$(32, vlen)
								IFZ XstCopyMemory (vptr, &buf$, vlen) THEN
									' Obtain language ID and codepage
									DIM x$[4]
										FOR x = 0 TO 3
								     nAsc = buf${x}
									     IF nAsc > 0xF THEN
								         x$[x] = HEX$(nAsc)
												ELSE
													x$[x] = "0" + HEX$(nAsc)
												END IF
									  NEXT
									LangStr$ = x$[1] + x$[0] + x$[3] + x$[2]

									' Obtain version information
									buf$ = "\\StringFileInfo\\" + LangStr$ + "\\FileVersion"
									lResult = VerQueryValueA (&vinfo@[0], &buf$, &vptr, &vlen)
									buf$ = CHR$(32,vlen)
									XstCopyMemory (vptr, &buf$, vlen)
										IF vlen > 17 THEN vlen = 17
									Ver$ = LEFT$(buf$, vlen - 1)
									' Obtain file description string
									buf$ = "\\StringFileInfo\\" + LangStr$ + "\\FileDescription"
									lResult = VerQueryValueA (&vinfo@[0], &buf$, &vptr, &vlen)
									buf$ = CHR$(32,vlen)
									XstCopyMemory (vptr, &buf$, vlen)
									Ver$ = Ver$ + "|" + LEFT$(buf$, vlen - 1)

									RETURN Ver$

								END IF
						END IF
				END IF
		END IF

	errflag = 1

	RETURN ret$

END FUNCTION
'
'
' *******************************
' ***** GetProcessorInfo () *****
' *******************************
'
FUNCTION STRING GetProcessorInfo ()

	cpu = XstGetCPUName(@id$, @cpuFamily, @model, @intelBrandID)

		SELECT CASE intelBrandID
			CASE 0
				SELECT CASE LCASE$(id$)
					CASE "genuineintel"
						m$ = "Intel "
						SELECT CASE cpuFamily
							CASE 4
							' 80486 Processors
							CASE 5
							' P5, P54C, P55C, P24T Porcessors
							CASE 6
							' P6, PII & PIII
								p$ = "Pentium "
								SELECT CASE model
									CASE 0, 1
									' P6 Models
									CASE 3, 5, 6
									' PII Models
									t$ = "II "
									CASE 7, 8, 0xa, 0xb
									' PIII Models
									t$ = "III "
									CASE ELSE
								END SELECT
							CASE 7
							' Intel Merced (IA-64)
							CASE ELSE
						END SELECT
					CASE "authenticamd"
						m$ = "AMD "
						SELECT CASE cpuFamily
							CASE 4
							' 5x86 Processors
								SELECT CASE model
									CASE 3, 7
										t$ = "486DX2 "
									CASE 8, 9
										t$ = "486DX4 "
									CASE 0xe, 0xf
										t$ = "5x86 "
								END SELECT
							CASE 5
							' K5 or K6
								SELECT CASE model
									CASE 0
										t$ = "K5 (PR75/90/100) "
									CASE 1
										t$ = "K5 (PR120/133) "
									CASE 2
										t$ = "K5 PR166 "
									CASE 3
										t$ = "K5 PR200 "
									CASE 6, 7
										t$ = "K6 "
									CASE 8
										t$ = "K6-2 "
									CASE 9
										t$ = "K6-III "
									CASE 0xd
										t$ = "K6-2+/K6-III+ "
								END SELECT
							CASE 6
							' K7
								SELECT CASE model
									CASE 1, 2, 4, 6
									' Athlon Models
										t$ = "Athlon "
									CASE 3, 7
									' Duron Models
										t$ = "Duron "
									CASE ELSE
								END SELECT
						END SELECT

					CASE "cyrixinstead"
						m$ = "Cyrix "
							SELECT CASE cpuFamily
								CASE 4
									SELECT CASE model
										CASE 9
											t$ = "5x85"
									END SELECT
								CASE 5
									SELECT CASE model
										CASE 2
											t$ ="M1 6x86 "
									END SELECT
								CASE 6
									SELECT CASE model
										CASE 0
											t$ = "M2 6x86MX "
									END SELECT
							END SELECT
					CASE "nexgendriven"
						m$ = "NexGen "
					CASE "genuinetmx86"
						m$ = "TransMeta "
					CASE "centaurhauls"
						m$ = "Centaur "
					CASE "riseriserise"
						m$ = "Rise Technology "
					CASE "umc umc umc "
						m$ = "UMC "
					CASE ELSE
						m$ = "Unknown "
				END SELECT
			CASE 1, 3, 7
			' Celeron
			CASE 2, 4, 6
			' PIII
				m$ = "Intel Pentium III "
			CASE 8, 9, 0xa, 0xb, 0xe
			' P4
				m$ = "Intel Pentium 4 "
		END SELECT

	id$ = m$ + p$ + t$

	RETURN id$

END FUNCTION
'
'
' ************************
' ***** RunFromCD () *****
' ************************
'
FUNCTION RunFromCD ()

		exeFile$ = XstGetProgramFileName$ ()
		XstGetPathComponents(exeFile$, @path$, @drive$, @dir$, @filename$, @attributes)

		IF GetDriveTypeA (&drive$) = $$DriveTypeCDROM THEN RETURN ASC(drive$)

END FUNCTION
'
'
' *****************************
' ***** GetCDRomDrives () *****
' *****************************
'
FUNCTION STRING GetCDRomDrives ()

	XstGetDrives(@count, @drive$[], @type[], @type$[])
		DO WHILE count
				IF type[count] = $$DriveTypeCDROM THEN drive$ = drive$ + LEFT$(drive$[count],2)
			DEC count
		LOOP
	RETURN drive$

END FUNCTION
'
'
' ***********************
' ***** DoChecks () *****
' ***********************
'
FUNCTION DoChecks ()

	SHARED OSINFO pcinfo
	SHARED errflag

		r = GetOSInfo ()
		pcinfo.TotalMem = STRING$(GetInstalledRAM ()) + "Mb"
		pcinfo.INetBrowser = XtractFileName (GetAssociatedExe ("HTM"))
			IF pcinfo.INetBrowser = "" THEN
				errflag = 1
				pcinfo.INetBrowser = "No File Association"
				pcinfo.VerBrowser = "Not Available"
			ELSE
				XstParseStringToStringArray(GetVersionInfo (GetAssociatedExe ("HTM")),"|",@ver$[])
				pcinfo.VerBrowser = ver$[0]
				pcinfo.BrowserDesc = ver$[1]
			END IF
		pcinfo.AcroRdrExe = XtractFileName (GetAssociatedExe ("PDF"))
			IF pcinfo.AcroRdrExe = "" THEN
				errflag = 1
				pcinfo.AcroRdrExe = "No File Association"
				pcinfo.VerAcroRdr = "Not Available"
			ELSE
				XstParseStringToStringArray(GetVersionInfo (GetAssociatedExe ("PDF")),"|",@ver$[])
				pcinfo.VerAcroRdr = ver$[0]
				pcinfo.AcroRdrDesc = ver$[1]
			END IF
		pcinfo.HostFile = CheckHost (@"localhost")
			IF IsIPInstalled () THEN
				tcp$ = "Yes"
			ELSE
				tcp$ = "No"
				errflag = 1
			END IF
		pcinfo.NetPresent = tcp$

' uncomment this line to write to registry
'		IFZ errflag THEN WriteRegEntry ()

	RETURN errflag

END FUNCTION
END PROGRAM
