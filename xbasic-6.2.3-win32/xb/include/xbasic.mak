# xbasic.mak - nmake include-file for XBasic

.SUFFIXES: .o .s .x

# The linker
LD          = link

# Flags for the linker
LDFLAGS     = /NODEFAULTLIB /SUBSYSTEM:WINDOWS /INCREMENTAL:NO /RELEASE /NOLOGO

# Flags for the linker when building .dll-files
LDFLAGS_DLL = -dll -subsystem:windows,4.0

# Needed resources
RESOURCES   = xb.rbj

# The assembler
AS          = spasm

# All needed standard libraries.
STDLIBS     = msvcrt.lib kernel32.lib advapi32.lib user32.lib gdi32.lib \
              comdlg32.lib winspool.lib

# The XBasic compiler
XB          = xb

# Default rule to assemble an assembly-file into an object-file.
.s.o:
	$(AS) $?

# Default rule to compile an XBasic-file into an object-file.
.x.s:
	$(XB) $?
