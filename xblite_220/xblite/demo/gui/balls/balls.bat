@ECHO OFF
REM This batch file creates the screensaver "Colliding Balls.scr"
REM using the makefile makeballs.mak.
REM The custom makefile incorporates the runtime DLL xb.dll
REM into the executable file.

SET XBLDIR=C:\xblite
SET PATH=C:\xblite\bin;%PATH%
SET LIB=C:\xblite\lib
SET INCLUDE=C:\xblite\include
nmake -f makeballs.mak all clean