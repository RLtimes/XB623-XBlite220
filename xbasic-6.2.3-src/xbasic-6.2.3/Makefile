# This is the main XBasic makefile
#
# Use:
#	make			To compile all sources
#	make install		To install
#	make clean		To remove all unneeded files
#
#	make dist-bin		To create a binary .tar.gz distribution
#	make dist-bin-zip	To create a binary .zip distribution
#	make dist-bin-rpm	To create a binary .rpm distribution (Linux
#				only)
#	make dist-bin-exe	To create a binary, self-installing .exe
#				distribution (Windows only)
#
#	make dist-src		To create a source .tar.gz distribution
#	make dist-src-zip	To create a source .zip distribution
#
#	make dist		To create the default set of distributions
#
#	make dist-* only works from the CVS source-tree, NOT from a source
#	distribution.
#
# Environment Variables:
# - XBDIR	The directory in which XBasic will be install when using
#		'make install'. This defaults to /usr/xb-$(VERSION) (note:
#		on Win32 too! Which probably is not what you want so you'd
#		better set XBDIR on Win32).
# Note:
# To use this makefile on Win32 you need to have Cygwin installed.
# Cygwin is available from http://sourceware.cygnus.com/cygwin/
# Note that on cygwin: /usr = %SystemDrive%\usr, //c/usr is c:\usr
# Update: Cygwin 1.0 seems to support C:\....
#

VERSION = 6
PATCHLEVEL = 2
SUBLEVEL = 3

RELEASE = 1

.PHONY: all install clean dist

# 'Autodetect' the operating system
# If it's not Linux then it's win32
SYSTEM=win32
ifeq '$(OSTYPE)' ''
  OSTYPE	= $(shell uname)
endif
ifneq '$(findstring Linux,$(OSTYPE))' ''
  SYSTEM	= linux
endif
ifneq '$(findstring LINUX,$(OSTYPE))' ''
  SYSTEM	= linux
endif
ifneq '$(findstring linux,$(OSTYPE))' ''
  SYSTEM	= linux
endif

ifeq '$(SYSTEM)' 'linux'
  DISTOS	= linux-i386
else
  DISTOS	= win32
endif

PLATFORM	= i386

ifeq '$(SYSTEM)' 'linux'
  MD		= mkdir -p
  E		=
  ZIP		= zip
  ZIPFLAGS	= -R -9 -y
  ALLFILES	= "*"
else
  # Note: Use mkdir.exe instead of 'builtin' mkdir because mkdir cannot handle
  # slashes.
  MD		= mkdir.exe -p
  E		= .exe
  ZIP		= pkzip
  ZIPFLAGS	= /Add /Maximum /Directories
  ALLFILES	= "*.*"
endif

VER=$(VERSION).$(PATCHLEVEL).$(SUBLEVEL)

# The directory in which XBasic will be installed. Every release is put in a
# separate subdirectory. All XBasic files will be installed in this directory.
#
# The following symbolic links are used:
# /usr/xb		-> $XBDIR
# /usr/bin/xb		-> /usr/xb/bin/xb
# /usr/lib/libxb.a	-> /usr/xb/lib/libxb.a

ifeq ($(MAKELEVEL),0)
  INSTROOT=
  ifeq '$(XBDIR)' ''
    ifeq '$(SYSTEM)' 'win32'
      # No default installation directory for Win32
      INSTDIR=
    else
      INSTDIR=/usr/xb-$(VER)
    endif
  else
    INSTDIR=$(XBDIR)

    # For Win32: The name of the XBasic directory can contain spaces (e.g.
    # C:\Program Files\XBasic). If so, put it inside quotes (Cygwin seems
    # to handle things like "C:\Program Files\XBasic"\bin correctly.
    # Also: replace \ by /; Cygwin/make likes / better
    ifeq '$(SYSTEM)' 'win32'
      INSTDIR:=$(subst \,/,$(INSTDIR))
      ifeq '$(words $(INSTDIR))' '1'
      else
        INSTDIR:="$(INSTDIR)"
      endif
    endif
  endif
  MAKEDIST=FALSE
else
  MAKEDIST=TRUE
endif

all:
	(cd src; make mkdir; make all)

clean:
	rm -rf dist
	rm -f XBasic.iss
	(cd src; make clean)

install: inst-bin

inst-bin:
ifeq '$(INSTDIR)' ''
	@echo "No directory to install to."
	@echo "Use XBDIR environment-variable to specify one."
else
	-$(MD) $(INSTDIR)
	-$(MD) $(INSTDIR)/lib
	-$(MD) $(INSTDIR)/include
	-$(MD) $(INSTDIR)/bin
	-$(MD) $(INSTDIR)/templates
	-$(MD) $(INSTDIR)/help
  ifeq '$(MAKEDIST)' 'TRUE'
	-$(MD) $(INSTDIR)/images
	-$(MD) $(INSTDIR)/demo
  endif
  ifeq '$(SYSTEM)' 'linux'
	cp src/bin/xb				$(INSTDIR)/bin
	cp src/bin/libxb.a			$(INSTDIR)/lib
	# Create links to the xb-binary and xb-library
	-$(MD) $(INSTROOT)/usr/bin
	-$(MD) $(INSTROOT)/usr/lib
	-rm -f $(INSTROOT)/usr/xb
	ln -sf /usr/xb-$(VER)			$(INSTROOT)/usr/xb
	ln -sf /usr/xb-$(VER)/bin/xb		$(INSTROOT)/usr/bin/xb
	ln -sf /usr/xb-$(VER)/lib/libxb.a	$(INSTROOT)/usr/lib
  else
	cp src/bin/xb.exe			$(INSTDIR)/bin
	cp src/bin/xb.dll			$(INSTDIR)/bin
	cp src/bin/xbrun.dll			$(INSTDIR)/bin
	cp src/bin/xb.lib			$(INSTDIR)/lib
	cp src/xb.rbj				$(INSTDIR)/lib
	cp src/win32/lib/xstart.o		$(INSTDIR)/lib
    ifeq '$(MAKEDIST)' 'TRUE'
	# These files are not available in the source-only distribution
	cp bin/win32/*.exe			$(INSTDIR)/bin
	cp bin/win32/*.dll			$(INSTDIR)/bin
	cp bin/win32/*.err			$(INSTDIR)/bin
	cp bin/win32/*.bat			$(INSTDIR)/bin
	cp lib/*.lib				$(INSTDIR)/lib
	cp include/win32/*.mak			$(INSTDIR)/include

	# This file is not needed in the XBasic directory
	cp src/xexcept.obj			$(INSTDIR)/src
    endif
  endif
	cp README.Linux				$(INSTDIR)
	cp README.Win32				$(INSTDIR)
	cp COPYING				$(INSTDIR)
	cp COPYING_LIB				$(INSTDIR)
	cp include/*.dec			$(INSTDIR)/include
	cp src/$(SYSTEM)/*.dec			$(INSTDIR)/include
	cp src/shared/*.dec			$(INSTDIR)/include
	cp templates/*.xxx			$(INSTDIR)/templates
	cp templates/*.bin			$(INSTDIR)/templates
	cp templates/$(SYSTEM)/*.xxx		$(INSTDIR)/templates
	cp help/*.hlp				$(INSTDIR)/help
  ifeq '$(MAKEDIST)' 'TRUE'
	# These files are not available in the source-only distribution
	cp demo/*.x				$(INSTDIR)/demo
	cp demo/*.win				$(INSTDIR)/demo
	cp demo/*.dat				$(INSTDIR)/demo
	cp images/*.bmp				$(INSTDIR)/images
	cp images/$(SYSTEM)/*.bmp		$(INSTDIR)/images
	cp images/*.cur				$(INSTDIR)/images
	cp images/$(SYSTEM)/*.cur		$(INSTDIR)/images
	cp images/*.msk				$(INSTDIR)/images
	cp images/*.gif				$(INSTDIR)/images
	cp images/*.bmp				$(INSTDIR)/images
	cp images/$(SYSTEM)/*.ico		$(INSTDIR)/images
	cp images/*.map				$(INSTDIR)/images
  endif
endif

inst-src:
ifeq ($(MAKELEVEL),0)
	@echo "Don't call 'make inst-src' directly"
else
	-$(MD) $(INSTDIR)
	-$(MD) $(INSTDIR)/src/shared/lib
	-$(MD) $(INSTDIR)/src/linux/lib
	-$(MD) $(INSTDIR)/src/win32/lib
	-$(MD) $(INSTDIR)/include
	-$(MD) $(INSTDIR)/templates
	-$(MD) $(INSTDIR)/templates/linux
	-$(MD) $(INSTDIR)/templates/win32
	-$(MD) $(INSTDIR)/help
	-$(MD) $(INSTDIR)/images
	-$(MD) $(INSTDIR)/images/win32
	cp Makefile				$(INSTDIR)
	cp src/shared/*.x			$(INSTDIR)/src/shared
	cp src/linux/*.x			$(INSTDIR)/src/linux
	cp src/linux/*.c			$(INSTDIR)/src/linux
	cp src/win32/*.x			$(INSTDIR)/src/win32
	cp src/win32/xb.def			$(INSTDIR)/src/win32
	cp src/win32/xb.rc			$(INSTDIR)/src/win32
	cp src/linux/lib/*.s			$(INSTDIR)/src/linux/lib
	cp src/win32/lib/*.s			$(INSTDIR)/src/win32/lib
	cp src/Makefile				$(INSTDIR)/src
	cp src/xexcept.obj			$(INSTDIR)/src
	cp include/*.dec			$(INSTDIR)/include
	cp README.Linux				$(INSTDIR)
	cp README.Win32				$(INSTDIR)
	cp COPYING				$(INSTDIR)
	cp COPYING_LIB				$(INSTDIR)
	cp templates/*.xxx			$(INSTDIR)/templates
	cp templates/*.bin			$(INSTDIR)/templates
	cp templates/linux/*.xxx		$(INSTDIR)/templates/linux
	cp templates/win32/*.xxx		$(INSTDIR)/templates/win32
	cp help/*.hlp				$(INSTDIR)/help
	cp images/win32/*.cur			$(INSTDIR)/images/win32
	cp images/win32/*.ico			$(INSTDIR)/images/win32
endif

# We must be able to built the .rpm from the rpmsrc-tar.gz file, so it must
# include some additional files (demos, ...).
inst-rpmsrc: inst-src
ifeq ($(MAKELEVEL),0)
	@echo "Don't call 'make inst-src' directly"
else
	-$(MD) $(INSTDIR)/demo
	-$(MD) $(INSTDIR)/images
	-$(MD) $(INSTDIR)/images/$(SYSTEM)
	cp demo/*.x				$(INSTDIR)/demo
	cp demo/*.win				$(INSTDIR)/demo
	cp demo/*.dat				$(INSTDIR)/demo
	cp images/*.bmp				$(INSTDIR)/images
	cp images/$(SYSTEM)/*.bmp		$(INSTDIR)/images/$(SYSTEM)
	cp images/*.cur				$(INSTDIR)/images
	cp images/$(SYSTEM)/*.cur		$(INSTDIR)/images/$(SYSTEM)
	cp images/*.msk				$(INSTDIR)/images
	cp images/*.gif				$(INSTDIR)/images
	cp images/*.bmp				$(INSTDIR)/images
	cp images/$(SYSTEM)/*.ico		$(INSTDIR)/images/$(SYSTEM)
	cp images/*.map				$(INSTDIR)/images
endif

# Build a .tar.gz file.
dist-bin:
	$(MAKE) inst-bin INSTROOT=/tmp/xbinst INSTDIR=/tmp/xbinst/usr/xb-$(VER)
	(cd /tmp/xbinst; tar cfz xbasic-$(VER)-$(DISTOS).tar.gz * --owner=root --group=root)
	-$(MD) dist
	cp /tmp/xbinst/xbasic-$(VER)-$(DISTOS).tar.gz dist
	rm -rf /tmp/xbinst

dist/xbasic-$(VER)-src.tar.gz: dist-src
dist/xbasic-$(VER)-rpmsrc.tar.gz: dist-rpmsrc

# Build a .RPM for Red Hat Linux systems
dist-bin-rpm: dist/xbasic-$(VER)-rpmsrc.tar.gz
	cat xbasic.spec.sed | \
		sed -e s/\$$VER/$(VER)/g | \
		sed -e s/\$$RELEASE/$(RELEASE)/g > \
		/usr/src/redhat/SPECS/xbasic-$(VER)-$(RELEASE).spec
	cp dist/xbasic-$(VER)-rpmsrc.tar.gz /usr/src/redhat/SOURCES
	rpm -ba /usr/src/redhat/SPECS/xbasic-$(VER)-$(RELEASE).spec
	cp /usr/src/redhat/RPMS/i386/xbasic-$(VER)-$(RELEASE).i386.rpm dist

# Build a .zip file.
dist-bin-zip:
ifeq '$(SYSTEM)' 'linux'
	$(MAKE) inst-bin INSTROOT=/tmp/xbinst INSTDIR=/tmp/xbinst/usr/xb-$(VER)
else
	$(MAKE) inst-bin INSTROOT=/tmp/xbinst INSTDIR=/tmp/xbinst/xb
endif
	(cd /tmp/xbinst; $(ZIP) $(ZIPFLAGS) xbasic-$(VER)-$(DISTOS).zip $(ALLFILES))
	-$(MD) dist
	cp /tmp/xbinst/xbasic-$(VER)-$(DISTOS).zip dist
	rm -rf /tmp/xbinst

# Build a self-installing executable
# Note: Compil32.exe is the setup-compiler from Inno Setup
dist-bin-exe: XBasic.iss
	compil32 /cc XBasic.iss

# Build a source .tar.gz file.
dist-src:
	$(MAKE) inst-src INSTDIR=/tmp/xbinst/xbasic-$(VER)
	(cd /tmp/xbinst; tar cfz xbasic-$(VER)-src.tar.gz * --owner=root --group=root)
	-$(MD) dist
	cp /tmp/xbinst/xbasic-$(VER)-src.tar.gz dist
	rm -rf /tmp/xbinst

# Build a source .tar.gz file (for rpm creation)
dist-rpmsrc:
	$(MAKE) inst-rpmsrc INSTDIR=/tmp/xbinst/xbasic-$(VER)
	(cd /tmp/xbinst; tar cfz xbasic-$(VER)-rpmsrc.tar.gz * --owner=root --group=root)
	-$(MD) dist
	cp /tmp/xbinst/xbasic-$(VER)-rpmsrc.tar.gz dist
	rm -rf /tmp/xbinst

# Build a source .zip file.
dist-src-zip:
	$(MAKE) inst-src INSTDIR=/tmp/xbinst/xbasic-$(VER)
	(cd /tmp/xbinst; $(ZIP) $(ZIPFLAGS) xbasic-$(VER)-src.zip $(ALLFILES))
	-$(MD) dist
	cp /tmp/xbinst/xbasic-$(VER)-src.zip dist
	rm -rf /tmp/xbinst

# Build the default (system dependent) set of distribution files.
dist:
ifeq '$(SYSTEM)' 'linux'
	make dist-bin
	make dist-bin-rpm
	make dist-src
else
	make dist-bin-zip
	make dist-bin-exe
	make dist-src-zip
endif

# Build a .iss-file (script for Inno Setup)
XBasic.iss: XBasic.iss.sed Makefile
	cat XBasic.iss.sed | \
		sed -e s/\$$VER/$(VER)/g | \
		sed -e s/\$$RELEASE/$(RELEASE)/g > \
		XBasic.iss

install-dec:
ifeq '$(SYSTEM)' 'linux'
	cp include/*.dec /usr/xb/include
endif

