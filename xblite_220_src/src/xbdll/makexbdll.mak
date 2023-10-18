# makefile - Build the XBLite runtime library - xbl.dll
#
# The following files are built
# - xbl.lib		Imports for the XBLite runtime library
# - xbl.dll		The XBLite runtime library

APP		= xbl
AS		= goasm
LD		= link
#LDFLAGS1	= -dll -subsystem:windows,4.0 -debug:partial -debugtype:coff
#LDFLAGS1	= -dll -subsystem:console -entry:DllMain
LDFLAGS1	= -dll -subsystem:console
DIR       	= $(XBLDIR)

AR		= lib
ARFLAGS	= -machine:i386
#LIBS		= msvcrt.lib kernel32.lib advapi32.lib user32.lib gdi32.lib comdlg32.lib winspool.lib
LIBS		= xblib.lib kernel32.lib user32.lib msvcrt.lib 


START		= START /W

#XBLITEOBJS	= lib\xlib.obj xst.obj
XBLITEOBJS	= lib\*.obj xst.obj

DST		= $(APP).lib $(APP).dll


all:  $(DST)

$(APP).lib: $(XBLITEOBJS)
	$(AR) $(ARFLAGS) -def:$(APP).def -out:$(APP).lib $(XBLITEOBJS)

$(APP).exp: $(APP).lib

$(APP).dll: $(XBLITEOBJS) $(APP).def $(APP).lib $(APP).exp
	$(LD) $(LDFLAGS1) -out:$(APP).dll $(XBLITEOBJS) $(APP).exp $(LIBS)

# lib\xlib.obj:     lib\xlib.asm
#			$(AS) lib\xlib.asm

xst.obj:          xst.asm
			$(AS) xst.asm

xst.asm:          xst.x
                $(START) xblite xst.x -lib

clean:
	IF EXIST $(APP).exp DEL $(APP).exp
	IF EXIST *.asm DEL *.asm
	IF EXIST *.rc DEL *.rc
	IF EXIST xst.def DEL xst.def
	IF EXIST xst.bat DEL xst.bat
	IF EXIST xst.mak DEL xst.mak

install:
	COPY $(APP).dll $(DIR)\bin\$(APP).dll
	COPY $(APP).dll $(DIR)\programs\$(APP).dll
	COPY $(APP).lib $(DIR)\lib\$(APP).lib
	COPY xst.dec $(DIR)\include\xst.dec

