'
' ####################  
' #####  XBLite  #####  xblite@yahoo.com
' ####################  XBLite (c) David Szafranski 2002-2006
'
' July 2005
'
' Download current version of XBLite from:
' http://perso.wanadoo.fr/xblite/

' XBLite mailing list:
' http://groups-beta.google.com/group/xblite

' XBasic webite:
' http://www.xbasic.org
'
' xblite@yahoo.com
' XBLite libraries and help files (c) 2005-2006 GPL David SZAFRANSKI 
'
' XBLite for Windows is a variation of XBasic
' designed to enhance XBasic's use with Windows
' and Windows GUI controls.
'
' XBLite installation is discussed below.
' XBLite will not work properly if you install XBLite incorrectly.
'
' XBasic/XBlite is subject to GPL and LGPL licenses, copies of which
' are included with this distribution in files COPYING and COPYING_LIB
' for your reference.  Which license applies to a particular file is
' specified in the file.
'
' The HTML Help Manual can be found in the \xblite\manual\ folder.
'
'
' ###############################
' #####  Installing XBLite  #####
' ###############################
'
' Windows XBLite is distributed in the following form:

' - A zip-file:
'   Extract the zip-file into c:\ root by using a program like
'   WinZip. Make SURE to "recreate directories". This will
'   create a \xblite directory and copy all necessary files
'   and folders to their required directories.
'
' The installation process does not alter the Windows system registry.
'
' To be able to build standalone .exe/.dll files from the command-line, you
' have to run the xblitesetup.bat batch-file. This sets some environment 
' variables needed by the build-process. 

' A copy of xblitesetup.bat is copied to the \windows or \winnt directory.
' If you decide to install or move xblite directories to another location,
' you will need to modify this batch file to reflect those changes. 

' xblitesetup.bat should look like this (assuming you installed XBLite in
' c:\xblite:
'
@ECHO OFF
SET XBLDIR=C:\xblite
SET PATH=C:\xblite\bin;%PATH%
SET LIB=C:\xblite\lib;%LIB%
SET INCLUDE=C:\xblite\include;%INCLUDE%

' You can also copy/append the above SET commands to your
' existing ones in your c:\autoexec.bat file.  
'
' To be able to run standalone programs, xbl.dll, the runtime library,
' must be in the same directory as the program or it must be found 
' in the current PATH.
'
' It is a good idea to copy xbl.dll to the \windows or \winnt directory so
' it will always be available.
'
' XBLite does not use the windows registry. 
'
'
' #########################################
' #####  Compiling an XBLite Program  #####
' #########################################
' 
' To compile an XBLite executable (*.exe) file from
' a XBLite program file (*.x) file, follow these steps:
'
' Open a MS-DOS Prompt console window by going to the start menu:
'
' Start menu > Programs > MS-DOS Prompt
'
' Then change to the directory that contains your *.x program:
'
' > cd c:\xblite\myprogs\testprog.x
' > xblitesetup
' > xblite testprog.x
' > nmake -f testprog.mak
'
' The first time you run xblite to compile your program, it
' will generate several files automatically; a make file (*.mak),
' a batch file (*.bat), and a resource file (*.rc). For each
' DOS prompt console session, it is only necessary to call
' xblitesetup.bat just one time.
'
' Once you have a make file (*.mak), then all that is required
' to recompile your program is:
'
' > xblitesetup
' > nmake -f yourprog.mak
'
' or
' > yourprog.bat
' 
'
' ##############################
' #####  Compiling XBLite  #####
' ##############################
'
' XBLite can be used to compile a new version of itself!
' The XBLite source files are contained in the \xblite\src\ 
' folder. Each component of XBLite has a make file and 
' batch file that can be used to rebuild the compiler, 
' xcowlite.dll, the runtime library, xbl.dll, and all of 
' the supporting libraries, xst, xma, xsx, xio, etc.
'
' To compile all of the XBLite from source files, it just
' requires running one or two batch files, makeall.bat
' and install.bat:
'
' At DOS prompt, change directory to \xblite\src
'
' >cd c:\xblite\src
' >makeall
' >install

' The batch file makeall.bat will create all the executable and
' library files while install.bat will copy the files to 
' the xblite\bin or xblite\programs directories.
'
'
' #################################
' #####  Uninstalling XBLite  #####
' #################################
'
' To uninstall XBLite, just delete the the XBLite folder \xblite.
' 
' To install a new version of XBLite, I would just rename the
' current xblite directory to something else like \xblite_v141\. 
' Then install the new version by unzipping it from the c:\ root
' directory. 

' This will give you a fresh install into a new \xblite\ folder.

' Then, if something goes wrong you can then just revert back to
' the previous version.


