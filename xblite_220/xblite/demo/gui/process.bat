echo Processing "%filename%"
if "%filename%"=="c:\xblite\demo\gui\buildall.bat" goto END
if "%filename%"=="c:\xblite\demo\gui\process.bat" goto END
if "%filename%"=="c:\xblite\demo\gui\temp.bat" goto END
cd "%filename%\.."
call "%filename%" 
:END
cd "c:\xblite\demo\gui"