@echo off
SET PATH=C:\xblite\bin;%PATH%

del *.obj

REM ****************************************************
REM Remember to add any new asm files below!
REM ****************************************************

REM ****************************************************
REM The Main routines, included in every program
REM ****************************************************

	GoAsm C:\xblite\src\xbdll\lib\xblib0.asm
	if errorlevel 1 goto error

REM ****************************************************
REM Memory routines
REM ****************************************************

	GoAsm C:\xblite\src\xbdll\lib\xblibm.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibm1.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibm2.asm
	if errorlevel 1 goto error

REM ****************************************************
REM Clone and concatenate routines
REM ****************************************************

	GoAsm C:\xblite\src\xbdll\lib\xblibcc.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibcc1.asm
	if errorlevel 1 goto error

REM ****************************************************
REM Low-level array processing
REM ****************************************************

	GoAsm C:\xblite\src\xbdll\lib\xbliba.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xbliba1.asm
	if errorlevel 1 goto error

REM ****************************************************
REM Composite String routines
REM ****************************************************

	GoAsm C:\xblite\src\xbdll\lib\xblibc.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibc1.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibc2.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibc3.asm
	if errorlevel 1 goto error

REM ****************************************************
REM XstStringToNumber ()
REM ****************************************************

	GoAsm C:\xblite\src\xbdll\lib\xblibn.asm
	if errorlevel 1 goto error

REM ****************************************************
REM PRINT routines
REM ****************************************************

	GoAsm C:\xblite\src\xbdll\lib\xblibp.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp1.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp2.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp3.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp4.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp5.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp6.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp7.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp8.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp9.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp10.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp11.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp12.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibp13.asm
	if errorlevel 1 goto error

REM ****************************************************
REM String routines
REM ****************************************************

	GoAsm C:\xblite\src\xbdll\lib\xblibs.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibs1.asm
	if errorlevel 1 goto error

	GoAsm C:\xblite\src\xbdll\lib\xblibs2.asm
	if errorlevel 1 goto error

REM Done

echo Objects sucessfully built.
goto finished
:error
echo Error building objects.
:finished
pause
