@ECHO OFF
SET XBLDIR=C:\xblite
SET PATH=C:\xblite\bin;%PATH%
SET LIB=C:\xblite\lib
SET INCLUDE=C:\xblite\include
xblite wm2name.x -lib
nmake -f wm2name.mak all clean