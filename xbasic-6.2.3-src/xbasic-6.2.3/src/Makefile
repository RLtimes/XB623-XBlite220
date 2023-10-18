# makefile - Build the XBasic executable and libraries
#
# For Linux
# bin/xb and bin/libxb.a are built.
#
# For Win32
# ---------
# The following files are built
# - bin/xb.exe		The main XBasic compiler/IDE executable.
# - bin/xb.lib		Imports for the XBasic runtime library
# - bin/xb.dll		The XBasic runtime library (version used by the PDE).
# - bin/xbrun.dll	The XBasic runtime library (version used by standalone
#			programs. You need to rename it to xb.dll (and make
#			certain it is found before the PDE-version of xb.dll;
#			e.g. by copying it to the current directory) to be able
#			to use it. This is temporary; in the future all
#			programs will use the default xb.dll.

# 'Autodetect' the operating system
# If it's not Linux then it's win32
SYSTEM=win32
ifeq '$(OSTYPE)' ''
  OSTYPE	= $(shell uname)
endif
ifneq '$(findstring Linux,$(OSTYPE))' ''
SYSTEM		= linux
endif
ifneq '$(findstring LINUX,$(OSTYPE))' ''
SYSTEM		= linux
endif
ifneq '$(findstring linux,$(OSTYPE))' ''
SYSTEM		= linux
endif

ifeq '$(SYSTEM)' 'win32'
AS	= spasm
LD	= link
LDFLAGS	= /NODEFAULTLIB /INCREMENTAL:NO /PDB:NONE /RELEASE /NOLOGO \
-subsystem:windows,4.0 -debug:partial -debugtype:coff
LDFLAGS1= -dll -subsystem:windows,4.0 -debug:partial -debugtype:coff

AR	= lib
ARFLAGS	= -machine:i386
LIBS	= kernel32.lib user32.lib gdi32.lib wsock32.lib msvcrt.lib

endif

ifeq '$(SYSTEM)' 'linux'
AS	= gcc
AFLAGS	= -c
LD	= gcc
AR	= ar
ARFLAGS	= rvs
CC	= gcc
CFLAGS	= -g -Wall -ggdb
endif

ifeq '$(SYSTEM)' 'win32'

XBRTLOBJS=		\
$(SYSTEM)/lib/xlib.o	\
xexcept.obj		\
$(SYSTEM)/xst.o		\
$(SYSTEM)/xin.o		\
shared/xma.o		\
shared/xcm.o		\
$(SYSTEM)/xgr.o		\
shared/xui.o		\
shared/xut.o		\
$(SYSTEM)/lib/xzzz.o	\

XBRUNOBJS=		\
$(XBRTLOBJS)		\
$(SYSTEM)/xrun.o	\

XBLIBOBJS=		\
$(XBRTLOBJS)		\
$(SYSTEM)/xit.o		\
$(SYSTEM)/xcow.o	\
shared/xdis.o		\
shared/xutpde.o		\

XBOBJS=			\
$(SYSTEM)/xbasic.o	\
$(SYSTEM)/lib/xstart.o	\

else

OBJS =			\
$(SYSTEM)/lib/xlib.o	\
$(SYSTEM)/xin.o		\
shared/xcm.o		\
shared/xma.o		\
$(SYSTEM)/xst.o		\
$(SYSTEM)/xgr.o		\
$(SYSTEM)/kernel32.o	\
$(SYSTEM)/gdi32.o	\
$(SYSTEM)/user32.o	\
$(SYSTEM)/xbiface.o	\
$(SYSTEM)/chkmem.o	\
shared/xui.o		\
shared/xut.o		\

XBOBJS=			\
$(SYSTEM)/lib/xstart.o	\
$(OBJS)			\
$(SYSTEM)/xit.o		\
$(SYSTEM)/xcol.o	\
shared/xdis.o		\
shared/xutpde.o		\
$(SYSTEM)/lib/xzzz.o	\


XBLIBOBJS=		\
$(SYSTEM)/lib/appstart.o\
$(SYSTEM)/xrun.o	\
$(OBJS)			\
$(SYSTEM)/lib/xzzz.o	\

endif

ifeq '$(SYSTEM)' 'win32'
DST=bin/xb.lib bin/xb.exe bin/xb.dll bin/xbrun.dll
endif

ifeq '$(SYSTEM)' 'linux'
DST=bin/xb bin/libxb.a
endif

all:	$(DST)

ifeq '$(SYSTEM)' 'win32'
bin/xb.lib: $(XBLIBOBJS)
	$(AR) $(ARFLAGS) -def:win32/xb.def -out:$@ $^

bin/xbrun.lib: $(XBRUNOBJS)
	$(AR) $(ARFLAGS) -def:win32/xb.def -out:$@ $^

bin/xb.exp: bin/xb.lib
bin/xbrun.exp: bin/xbrun.lib

bin/xb.exe: $(XBOBJS) xb.rbj bin/xb.lib
	$(LD) $(LDFLAGS) -out:bin/xb.exe $^ $(LIBS)

bin/xbrun.dll: $(XBRUNOBJS) xb.rbj bin/xbrun.exp
	$(LD) $(LDFLAGS1) -out:$@ $^ $(LIBS)

bin/xb.dll: $(XBLIBOBJS) bin/xb.exp
	$(LD) $(LDFLAGS1) -out:$@ $^ $(LIBS)

xb.rbj: xb.res
	cvtres -i386 xb.res -o xb.rbj

xb.res: win32/xb.rc
	rc -i../images/win32 -r -fo xb.res win32/xb.rc

endif

ifeq '$(SYSTEM)' 'linux'

bin/xb:	$(XBOBJS) bin/libxb.a
	$(CC) $(CFLAGS) $(XBOBJS) -rdynamic -L/usr/X11R6/lib -lX11 -lm -ldl -o bin/xb
	nm -g bin/xb > xlabs

bin/libxb.a: $(XBLIBOBJS)
	$(AR) $(ARFLAGS) $@ $^
endif

bin:
	mkdir bin

%.o: %.c
	$(CC) -c -g -ggdb $< -o $@

ifeq '$(SYSTEM)' 'win32'
%.o: %.s
	$(AS) $(AFLAGS) $<
else
%.o: %.s
	$(AS) $(AFLAGS) $< -o $@
endif

%.s: %.x
	xb $< -lib

win32/xbasic.s: win32/xbasic.x
	xb $<

mkdir:
	-mkdir bin

clean:
	-$(RM) bin/xb
	-$(RM) *.o
	-$(RM) linux/*.o
	-$(RM) win32/*.o
	-$(RM) shared/*.o
	-$(RM) linux/*.s
	-$(RM) win32/*.s
	-$(RM) shared/*.s
	-$(RM) linux/*.dec
	-$(RM) win32/*.dec
	-$(RM) shared/*.dec
	-$(RM) linux/*.def
	-$(RM) shared/*.def
	-$(RM) linux/lib/*.o
	-$(RM) win32/lib/*.o
	-$(RM) shared/lib/*.o
	-$(RM) xlabs
	-$(RM) bin/libxb.a
	-$(RM) bin/xb.lib
	-$(RM) bin/xb.dll
	-$(RM) bin/xb.exp
	-$(RM) bin/xb.exe
	-$(RM) bin/xbrun.lib
	-$(RM) bin/xbrun.dll
	-$(RM) bin/xbrun.exp
	-$(RM) xb.rbj
