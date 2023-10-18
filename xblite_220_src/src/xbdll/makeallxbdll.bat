@ECHO OFF
REM Batch file to build xb.dll/xb.lib

SET XBLDIR=C:\xblite
SET PATH=C:\xblite\bin;%PATH%
SET LIB=C:\xblite\lib
SET INCLUDE=C:\xblite\include

nmake -f makexbdll.mak all