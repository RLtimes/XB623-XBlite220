# Note: the next six lines are modified by the makefile-generator in xcowlite.x.
APP       = balls
LIBS      = xst_s.lib gdi32.lib user32.lib kernel32.lib msvcrt.lib comctl32.lib advapi32.lib
OBJS      = $(APP).obj
START     = START /W
XBLITE    = xblite
SUBSYSTEM = WINDOWS,4.0
SCRNAME   = Colliding Balls.scr

# The linker
LD          = link

# Flags for the linker
LDFLAGS     = /entry:WinMain /NODEFAULTLIB /SUBSYSTEM:$(SUBSYSTEM) /INCREMENTAL:NO /RELEASE /NOLOGO /OPT:REF /ALIGN:4096

# Needed resources
RESOURCES   = $(APP).rbj

# The assembler
AS          = goasm

# All needed standard libraries.
STDLIBS     = xblib.lib kernel32.lib advapi32.lib user32.lib gdi32.lib comdlg32.lib winspool.lib

# The main directory for \xblite
DIR         = $(XBLDIR)


all: $(APP).exe

$(APP).exe: $(APP).obj $(RESOURCES)
	$(LD) $(LDFLAGS) -out:$(APP).exe $(OBJS) $(RESOURCES) $(LIBS) $(STDLIBS)

$(APP).rbj: $(APP).res
	cvtres -i386 -NOLOGO $(APP).res -o $(APP).rbj

$(APP).res: $(APP).rc
	rc -i$(DIR)\images -r -fo $(APP).res $(APP).rc

$(APP).obj: $(APP).asm
	$(AS) $(APP).asm

$(APP).asm: $(APP).x
	$(START) $(XBLITE) $(APP).x

clean:
	IF EXIST $(APP).res DEL $(APP).res
	IF EXIST $(APP).rbj DEL $(APP).rbj
	IF EXIST $(APP).def DEL $(APP).def
	IF EXIST $(APP).obj DEL $(APP).obj
	IF EXIST $(APP).asm DEL $(APP).asm
	IF EXIST $(APP).mak DEL $(APP).mak
	IF EXIST "$(DIR)\programs\COLLID~1.SCR" DEL "$(DIR)\programs\COLLID~1.SCR"
	IF EXIST "COLLID~1.SCR" DEL "COLLID~1.SCR"
	IF EXIST $(APP).exe RENAME $(APP).exe "$(SCRNAME)"
	IF EXIST "$(APP).exe" DEL "$(APP).exe"
	IF EXIST "$(SCRNAME)" COPY "$(SCRNAME)" "$(DIR)\programs\$(SCRNAME)"
	START "$(DIR)\programs\$(SCRNAME)"
