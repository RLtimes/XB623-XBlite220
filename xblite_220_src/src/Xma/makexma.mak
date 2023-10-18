# makefile for xma.dll for XBLite for Windows
APP       = xma
LIBS      = xbl.lib
START	    = START /W

# The linker
LD          = link

# Flags for the linker
LDFLAGS     = /NODEFAULTLIB /SUBSYSTEM:WINDOWS,4.0 /INCREMENTAL:NO /RELEASE /NOLOGO /OPT:REF

# Flags for the linker when building .dll-files
LDFLAGS_DLL = -dll -subsystem:windows,4.0 -entry:DllMain

# The assembler
AS          = goasm

# All needed standard libraries.
STDLIBS     = kernel32.lib advapi32.lib user32.lib gdi32.lib \
              comdlg32.lib winspool.lib xblib.lib

OBJS        = xmalib.obj

# The XBasic Lite compiler
XBLITE      = xblite

# The main directory for \xblite
DIR         = $(XBLDIR)

all: $(APP).dll

#$(APP).lib: xmalib.obj
#	$(AR) $(ARFLAGS) -def:xmxxx.def -out:$(APP).lib xmalib.obj

$(APP).dll: $(APP).obj $(OBJS) xmxxx.def
	$(LD) $(LDFLAGS_DLL) -out:$(APP).dll $(OBJS) $(APP).obj -def:xmxxx.def $(LIBS) $(STDLIBS)

$(APP).obj: $(APP).asm
	$(AS) $(APP).asm

xmalib.obj: xmalib.asm
	$(AS) xmalib.asm

$(APP).asm: $(APP).x
	$(START) $(XBLITE) $(APP).x -lib

clean:
	IF EXIST $(APP).def DEL $(APP).def
	IF EXIST $(APP).obj DEL $(APP).obj
	IF EXIST $(APP).asm DEL $(APP).asm
	IF EXIST $(APP).exp DEL $(APP).exp
	IF EXIST $(APP).bat DEL $(APP).bat
	IF EXIST $(APP).mak DEL $(APP).mak

install:
	COPY /B $(APP).lib /B $(DIR)\lib\$(APP).lib /Y
	COPY /A $(APP).dec /A $(DIR)\include\$(APP).dec /Y
	COPY /B $(APP).dll /B $(DIR)\programs\$(APP).dll /Y