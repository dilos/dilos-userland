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
# Copyright (c) 2011, Nexenta Systems, Inc. All rights reserved.
# Copyright (c) 2011, OpenIndiana project. All rights reserved.
#
include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		gcc
COMPONENT_VERSION=	4.4.4
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH=	sha1:45d1e7242a08cbb7a343ed2bf640a5afd0ebe098
COMPONENT_ARCHIVE_URL=	http://ftp.gnu.org/gnu/gcc/$(COMPONENT_NAME)-$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)
COMPONENT_PROJECT_URL=  http://gcc.gnu.org/

CONFIGURE_DEFAULT_LDFLAGS = no
CONFIGURE_DEFAULT_CPPFLAGS = no

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include ../../make-rules/deb.mk

COMPILER = gcc
#JOBS = 8

# CC_BITS may get in the way
CC_BITS = 

# workarround plattform, EC uses PLAT makro, should be reimplemented in shared-macros.mk
# ore replaced
PLAT=$(shell uname -p | sed 's/i386/pc/;s/sparc/sun/')
PKG_MACROS += PLAT=$(PLAT)

#CPPFLAGS += -fexceptions

CFLAGS.sparc = -fkeep-inline-functions
CFLAGS = -g -O2
GMSGFMT = /usr/gnu/bin/msgfmt

#CONFIGURE_ENV += LDFLAGS="$(LDFLAGS)"

GMP_DIR = $(WS_COMPONENTS)/gnump/build/prototype/$(MACH)
MPFR_DIR = $(WS_COMPONENTS)/mpfr/build/prototype/$(MACH)

CONFIGURE_ENV +=	GMSGFMT="$(GMSGFMT)"

CONFIGURE_PREFIX    =		/usr/gcc/4.4
#CONFIGURE_OPTIONS  +=		CPPFLAGS="$(CPPFLAGS)"

CONFIGURE_OPTIONS  +=		--libexecdir=$(CONFIGURE_PREFIX)/lib
CONFIGURE_OPTIONS  +=		--mandir=$(CONFIGURE_PREFIX)/share/man
CONFIGURE_OPTIONS  +=		--infodir=$(CONFIGURE_PREFIX)/share/info
CONFIGURE_OPTIONS  +=		--enable-shared
CONFIGURE_OPTIONS  +=		--with-system-zlib

CONFIGURE_OPTIONS  +=		--with-gmp-include=/usr/include/gmp
#CONFIGURE_OPTIONS  +=		--with-gmp-include=$(GMP_DIR)/usr/include/gmp
#CONFIGURE_OPTIONS.32  +=	--with-gmp-lib=$(GMP_DIR)/usr/lib
#CONFIGURE_OPTIONS.64  +=	--with-gmp-lib=$(GMP_DIR)/usr/lib/$(MACH64)

CONFIGURE_OPTIONS  +=		--with-mpfr-include=/usr/include/mpfr
#CONFIGURE_OPTIONS  +=		--with-mpfr-include=$(MPFR_DIR)/usr/include/mpfr
#CONFIGURE_OPTIONS.32  +=	--with-mpfr-lib=$(MPFR_DIR)/usr/lib
#CONFIGURE_OPTIONS.64  +=	--with-mpfr-lib=$(MPFR_DIR)/usr/lib/$(MACH64)

CONFIGURE_OPTIONS.sparc +=	--without-gnu-as --with-as=/usr/ccs/bin/as
#CONFIGURE_OPTIONS.i386  +=	--with-gnu-as --with-as=$(SFWBIN)/gas
#CONFIGURE_OPTIONS.i386  +=	--with-gnu-as --with-as=/usr/gnu/bin/as
CONFIGURE_OPTIONS.i386  +=	--with-gnu-as --with-as=/usr/bin/gas
CONFIGURE_OPTIONS  +=           --with-ld=/usr/ccs/bin/ld
CONFIGURE_OPTIONS  +=           --without-gnu-ld
CONFIGURE_OPTIONS  +=           --enable-libstdcxx-allocator=mt
CONFIGURE_OPTIONS  +=           --enable-nls
CONFIGURE_OPTIONS  +=           --enable-objc-gc
CONFIGURE_OPTIONS  +=           --enable-libssp
CONFIGURE_OPTIONS  +=           --enable-c99
CONFIGURE_OPTIONS  +=           --with-pic
CONFIGURE_OPTIONS  +=           --enable-wchar_t
CONFIGURE_OPTIONS  +=           --enable-targets=$(GNU_ARCH64)
#CONFIGURE_OPTIONS  +=           --enable-stage1-languages=c
CONFIGURE_OPTIONS  +=           --enable-languages=c,c++,objc,fortran,obj-c++
##CONFIGURE_OPTIONS  +=           --with-stage1-ldflags="-L$(CONFIGURE_PREFIX)/lib -R$(CONFIGURE_PREFIX)/lib -L$(CONFIGURE_PREFIX)/lib/$(MACH64) -R$(CONFIGURE_PREFIX)/lib/$(MACH64)"
##CONFIGURE_OPTIONS  +=           --with-boot-ldflags="-L$(CONFIGURE_PREFIX)/lib -R$(CONFIGURE_PREFIX)/lib -L$(CONFIGURE_PREFIX)/lib/$(MACH64) -R$(CONFIGURE_PREFIX)/lib/$(MACH64)"
#CONFIGURE_OPTIONS  +=           --build=$(MACH)-$(PLAT)-solaris$(SOLARIS_VERSION)
#CONFIGURE_OPTIONS  +=           --build=$(GNU_ARCH)
#CONFIGURE_OPTIONS  +=		$(CONFIGURE_OPTIONS.$(MACH))
#CONFIGURE_OPTIONS  +=		CFLAGS="$(CFLAGS)"
#CONFIGURE_OPTIONS  +=		CFLAGS_FOR_BUILD="$(CFLAGS_FOR_BUILD)"
#CONFIGURE_OPTIONS  +=		STAGE1_CFLAGS="$(STAGE1_CFLAGS)"
#CONFIGURE_OPTIONS  +=		CFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)"
#CONFIGURE_OPTIONS  +=		GMSGFMT="$(GMSGFMT)"

PATH = /usr/gnu/bin:/usr/bin:/sbin:/usr/sbin:/usr/perl5/bin

#COMPONENT_BUILD_ENV += PATH="$(PATH):/usr/perl5/$(PERL_VERSION)/bin"
COMPONENT_BUILD_ENV += PATH="$(PATH)"

COMPONENT_BUILD_ENV += SHELL="$(CONFIG_SHELL)"
COMPONENT_BUILD_ENV += CFLAGS="$(CFLAGS)"
COMPONENT_BUILD_ENV += STAGE1_CFLAGS="$(CFLAGS)"
COMPONENT_BUILD_ENV += CFLAGS_FOR_TARGET="$(CFLAGS)"
COMPONENT_BUILD_ENV += CFLAGS_FOR_BUILD="$(CFLAGS)"
COMPONENT_BUILD_TARGETS = bootstrap

COMPONENT_INSTALL_ENV += PATH="$(PATH)"

include ../../make-rules/shared-targets.mk

#LD_OPTIONS = 

build:		$(BUILD_32)

install:	$(INSTALL_32)

tst:
	@echo $(LDFLAGS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
