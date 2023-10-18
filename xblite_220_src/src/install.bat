# batch file to install all XBLite 
# libraries into user folders

SET XBLDIR=C:\xblite
SET PATH=C:\xblite\bin;%PATH%
SET LIB=C:\xblite\lib
SET INCLUDE=C:\xblite\include

cd c:\xblite\src\xbdll\
nmake -f makexbdll.mak install

cd c:\xblite\src\xblite\
nmake -f makexblite.mak install

cd c:\xblite\src\xcowlite\
nmake -f makexcowlite.mak install

cd c:\xblite\src\xma\
nmake -f makexma.mak install

cd c:\xblite\src\xsx\
nmake -f makexsx.mak install

cd c:\xblite\src\xcm\
nmake -f makexcm.mak install

cd c:\xblite\src\xio\
nmake -f makexio.mak install