rem batch file to rebuild all XBLite source libraries
 
cd c:\xblite\src\xbdll\
call makexbdll
cd c:\xblite\src\xblite\
call makexblite
cd c:\xblite\src\xcowlite\
call makexcowlite
cd c:\xblite\src\xma\
call makexma
cd c:\xblite\src\xsx\
call makexsx
cd c:\xblite\src\xcm\
call makexcm
cd c:\xblite\src\xio\
call makexio
