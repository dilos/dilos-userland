#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
# Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved.
#
include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnupg
COMPONENT_VERSION=	2.0.18
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL=	http://www.gnupg.org/
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH=	sha1:5ec2f718760cc3121970a140aeea004b64545c46
COMPONENT_ARCHIVE_URL=	ftp://ftp.gnupg.org/gcrypt/gnupg/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

CFLAGS += $(CPP_LARGEFILES)

# If we pass -lc, -mt won't link with -lthread
# (which is what it does by default, and we don't
# want that, because we use POSIX threads).
#LDFLAGS += -lc -Wl,-z,defs
LDFLAGS += -lc

GNUPTH_DIR = $(WS_COMPONENTS)/gnupth/build/prototype/$(MACH)
LIBGPGERR_DIR = $(WS_COMPONENTS)/libgpg-error/build/prototype/$(MACH)
LIBASSUAN_DIR = $(WS_COMPONENTS)/libassuan/build/prototype/$(MACH)
LIBKSBA_DIR = $(WS_COMPONENTS)/libksba/build/prototype/$(MACH)
READLINE_DIR = $(WS_COMPONENTS)/readline/build/prototype/$(MACH)

CPPFLAGS += -I$(GNUPTH_DIR)/usr/include
CPPFLAGS += -I$(LIBASSUAN_DIR)/usr/include
CPPFLAGS += -I$(READLINE_DIR)/usr/include
CPPFLAGS += -I$(LIBGPGERR_DIR)/usr/include
CPPFLAGS += -I$(LIBKSBA_DIR)/usr/include

LDFLAGS += -L$(GNUPTH_DIR)/usr/lib
LDFLAGS += -L$(LIBASSUAN_DIR)/usr/lib
LDFLAGS += -L$(READLINE_DIR)/usr/lib
LDFLAGS += -L$(LIBGPGERR_DIR)/usr/lib
LDFLAGS += -L$(LIBKSBA_DIR)/usr/lib

CONFIGURE_OPTIONS  +=		--localstatedir=/var
CONFIGURE_OPTIONS  +=		--libexecdir=$(USRBINDIR)
CONFIGURE_OPTIONS  +=		--datadir=$(CONFIGURE_PREFIX)/share
CONFIGURE_OPTIONS  +=		--sysconfdir=/etc
CONFIGURE_OPTIONS  +=		--infodir=$(CONFIGURE_INFODIR)
CONFIGURE_OPTIONS  +=		--disable-rpath
CONFIGURE_OPTIONS  +=		--enable-nls
CONFIGURE_OPTIONS  +=		--enable-gpg
CONFIGURE_OPTIONS  +=		--enable-gpgsm
CONFIGURE_OPTIONS  +=		--enable-agent
CONFIGURE_OPTIONS  +=		--enable-scdaemon
CONFIGURE_OPTIONS  +=		--enable-gpgtar
CONFIGURE_OPTIONS  +=		--enable-largefile
CONFIGURE_OPTIONS  +=		--disable-selinux-support
CONFIGURE_OPTIONS  +=		--with-pinentry-pgm=$(CONFIGURE_PREFIX)/lib/pinentry
#CONFIGURE_OPTIONS  +=		--with-gpg-error-prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-gpg-error-prefix=$(LIBGPGERR_DIR)/usr
#CONFIGURE_OPTIONS  +=		--with-libassuan-prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-libassuan-prefix=$(LIBASSUAN_DIR)/usr
#CONFIGURE_OPTIONS  +=		--with-ksba-prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-ksba-prefix=$(LIBKSBA_DIR)/usr
#CONFIGURE_OPTIONS  +=		--with-pth-prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-pth-prefix=$(GNUPTH_DIR)/usr
CONFIGURE_OPTIONS  +=		--with-libcurl=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-libiconv-prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-libintl-prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-zlib=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-bzip2=$(CONFIGURE_PREFIX)
#CONFIGURE_OPTIONS  +=		--with-readline=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-readline=$(READLINE_DIR)/usr

COMPONENT_INSTALL_ENV += LD_LIBRARY_PATH=$(READLINE_DIR)/usr/lib:$(LIBASSUAN_DIR)/usr/lib:$(LD_LIBRARY_PATH)

LIBKSBA_MANIFEST = 	manifest-$(MACH)-libksba.depend
LIBASSUAN_MANIFEST =	manifest-$(MACH)-libassuan.depend
#GPGME_MANIFEST =	manifest-$(MACH)-gpgme.depend
PINENTRY_MANIFEST =	manifest-$(MACH)-pinentry.depend
GNUPTH_MANIFEST =	manifest-$(MACH)-gnupth.depend
READLINE_MANIFEST =	manifest-$(MACH)-readline.depend

# Work around pkgdepend bug which doesn't resolve dependencies from
# the local workspace repo. Fortunately we only have to do this once.
DEPENDED +=	$(WS_TOP)/components/libksba/build/$(LIBKSBA_MANIFEST)
DEPENDED +=	$(WS_TOP)/components/libassuan/build/$(LIBASSUAN_MANIFEST)
#DEPENDED +=	$(WS_TOP)/components/gpgme/build/$(GPGME_MANIFEST)
DEPENDED +=	$(WS_TOP)/components/pinentry/build/$(PINENTRY_MANIFEST)
DEPENDED +=	$(WS_TOP)/components/gnupth/build/$(GNUPTH_MANIFEST)
DEPENDED +=	$(WS_TOP)/components/readline/build/$(READLINE_MANIFEST)

PKG_PROTO_DIRS += $(WS_TOP)/components/libksba
PKG_PROTO_DIRS += $(WS_TOP)/components/libassuan
#PKG_PROTO_DIRS += $(WS_TOP)/components/gpgme
PKG_PROTO_DIRS += $(WS_TOP)/components/pinentry

MAN8LIST = addgnupghome applygnupgdefaults

build: $(BUILD_32)

install: $(INSTALL_32)
	( cd $(PROTOUSRSHARELOCALEDIR) ; \
	    $(CP) -R 'en@boldquot' en )
	( cd $(PROTOUSRSHAREMANDIR) ; \
	    if test -d man8 ; then \
	    $(MV) man8 man1m ; fi )
	( cd $(PROTOUSRSHAREMANDIR)/man1m ; \
	    list1='$(MAN8LIST)' ; for f in $$list1; do \
	    if test -f $$f.8 ; then \
	    $(MV) $$f.8 $$f.1m ; fi ; \
	    done )

test: $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk

