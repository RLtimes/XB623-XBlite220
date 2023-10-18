@ECHO OFF
REM This batch file runs every batch file
REM in all subfolders in order to build
REM all the gui programs.
REM help on batch file at http://www.ericphelps.com/batch/

dir *.bat /s /b /l >filelist.txt

:START 
copy fragment.txt + filelist.txt temp.txt > nul 
type temp.txt | find "set filename=" > temp.bat
echo call process.bat >> temp.bat
call temp.bat 
type temp.txt | find /v "set filename=" > filelist.txt 
copy filelist.txt nul | find "0" > nul
if errorlevel 1 goto START 

del filelist.txt
del temp.bat
del temp.txt

