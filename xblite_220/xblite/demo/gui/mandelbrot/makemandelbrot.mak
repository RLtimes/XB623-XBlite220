# Note: the next six lines are modified by the makefile-generator in xcowlite.x.
APP       = mandelbrot
LIBS      = xbl.lib gdi32.lib user32.lib kernel32.lib comctl32.lib msvcrt.lib comdlg32.lib
OBJS      = $(APP).o
START     = START /W
XBLITE    = xblite
SUBSYSTEM = WINDOWS,4.0

# The linker
LD          = polink

# Flags for the linker
LDFLAGS     = /entry:WinMain /NODEFAULTLIB /SUBSYSTEM:$(SUBSYSTEM) /INCREMENTAL:NO /RELEASE /NOLOGO /OPT:REF /ALIGN:4096

# Needed resources
RESOURCES   = $(APP).res

# The assembler
AS          = spasm

# All needed standard libraries.
STDLIBS     = kernel32.lib advapi32.lib user32.lib gdi32.lib comdlg32.lib winspool.lib

# The main directory for \xblite 
DIR         = $(XBLDIR)


all: $(APP).exe

$(APP).exe: $(APP).o $(RESOURCES)
	$(LD) $(LDFLAGS) -out:$(APP).exe $(OBJS) $(RESOURCES) $(LIBS) $(STDLIBS)

#$(APP).rbj: $(APP).res
#	cvtres -i386 -NOLOGO $(APP).res -o $(APP).rbj

$(APP).res: $(APP).rc
	porc -i$(DIR)\images -r -fo $(APP).res $(APP).rc

$(APP).o: $(APP).s
	$(AS) $(APP).s

$(APP).s: $(APP).x
	$(START) $(XBLITE) $(APP).x

clean:
#	IF EXIST $(APP).res DEL $(APP).res
#	IF EXIST $(APP).rbj DEL $(APP).rbj
	IF EXIST $(APP).def DEL $(APP).def
	IF EXIST $(APP).o DEL $(APP).o
	IF EXIST $(APP).s DEL $(APP).s
	IF EXIST $(DIR)\programs\$(APP).exe DEL $(DIR)\programs\$(APP).exe
	COPY $(APP).exe $(DIR)\programs\$(APP).exe
	START $(DIR)\programs\$(APP).exe
