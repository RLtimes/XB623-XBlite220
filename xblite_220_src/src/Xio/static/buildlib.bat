@echo off 
SET XBLDIR=C:\xblite  
SET PATH=C:\xblite\bin;%PATH% 
SET LIB=C:\xblite\lib 
SET INCLUDE=C:\xblite\include 
GoAsm c:\xblite\src\xio\static\xio_s.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioClearEndOfLine.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioDeleteLine.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioGetConsoleInfo.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioGetConsoleTextRect.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioGetStdIn.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioGetStdOut.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioGrabConsoleText.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioInsertLine.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioPutConsoleText.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioPutConsoleTextArray.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioScrollBufferUp.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioSetConsoleBufferSize.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioSetConsoleCursorPos.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioSetConsoleTextRect.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioSetCursorType.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioCloseStdHandle.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioClearConsole.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioHideConsole.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioShowConsole.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioCreateConsole.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioGetConsoleWindow.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioWriteConsole.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioReadConsole.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioFreeConsole.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioSetTextAttributes.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioSetTextBackColor.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioSetTextColor.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioSetDefaultColors.asm  
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\XioInkey.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\DisplayConsole.asm 
if errorlevel 1 goto error  
GoAsm c:\xblite\src\xio\static\GetConsoleHandle.asm 
if errorlevel 1 goto error  
polib c:\xblite\src\xio\static\*.obj /out:c:\xblite\src\xio\static\xio_s.lib  
if errorlevel 1 goto error  
copy c:\xblite\src\xio\static\xio_s.lib c:\xblite\lib\xio_s.lib 
copy c:\xblite\src\xio\static\xio_s.dec c:\xblite\include\xio_s.dec 
echo Library completed. 
goto finished 
:error  
echo Error making Library.  
goto end  
:finished 
del c:\xblite\src\xio\static\*.obj  
del c:\xblite\src\xio\xio.asm 
:end  
pause 
