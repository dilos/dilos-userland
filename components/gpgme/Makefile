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

PATH = /usr/gnu/bin:/usr/bin

COMPONENT_NAME=		gpgme
COMPONENT_VERSION=	1.1.8
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL=	http://www.gnupg.org/related_software/gpgme/
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_URL=	ftp://ftp.gnupg.org/gcrypt/gpgme/$(COMPONENT_ARCHIVE)
COMPONENT_ARCHIVE_HASH=	sha1:e56da614f3e6acc1cb51af767c77f4a95b05b1e8

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

LIBGPGERR_DIR = $(WS_COMPONENTS)/libgpg-error/build/prototype/$(MACH)
GNUPTH_DIR = $(WS_COMPONENTS)/gnupth/build/prototype/$(MACH)
LIBASSUAN_DIR = $(WS_COMPONENTS)/libassuan/build/prototype/$(MACH)

PATCH_LEVEL = 0

CFLAGS += $(CPP_LARGEFILES)

CPPFLAGS += -I$(GNUPTH_DIR)/usr/include
CPPFLAGS += -I$(LIBASSUAN_DIR)/usr/include
CPPFLAGS += -I$(LIBGPGERR_DIR)/usr/include

LDFLAGS.32 += -L$(LIBGPGERR_DIR)/usr/lib
LDFLAGS.64 += -L$(LIBGPGERR_DIR)/usr/lib/$(MACH64)

LDFLAGS.32 += -L$(GNUPTH_DIR)/usr/lib
LDFLAGS.64 += -L$(GNUPTH_DIR)/usr/lib/$(MACH64)

LDFLAGS.32 += -L$(LIBASSUAN_DIR)/usr/lib
LDFLAGS.64 += -L$(LIBASSUAN_DIR)/usr/lib/$(MACH64)
#LDFLAGS += $(LDFLAGS.$(BITS))

CONFIGURE_OPTIONS  +=		--localstatedir=/var
CONFIGURE_OPTIONS  +=		--infodir=$(CONFIGURE_INFODIR)
CONFIGURE_OPTIONS  +=		--enable-shared
CONFIGURE_OPTIONS  +=		--disable-static
CONFIGURE_OPTIONS  +=		--enable-largefile
#CONFIGURE_OPTIONS  +=		--with-pth=$(GNUPTH_DIR)/usr
CONFIGURE_OPTIONS  +=		--with-pth=yes
CONFIGURE_OPTIONS  +=		--without-pth-test

CONFIGURE_OPTIONS  +=		--disable-glibtest
CONFIGURE_OPTIONS  +=		--disable-gpg-test
CONFIGURE_OPTIONS  +=		--disable-gpgsm-test
CONFIGURE_OPTIONS  +=		--disable-gpgconf-test

CONFIGURE_OPTIONS  +=		--with-gpg=$(USRBINDIR)/gpg2
CONFIGURE_OPTIONS  +=		--with-gpgsm=$(USRBINDIR)/gpgsm
CONFIGURE_OPTIONS  +=		--with-gpgconf=$(USRBINDIR)/gpgconf
CONFIGURE_OPTIONS  +=		--with-pic

LIBASSUAN_MANIFEST = manifest-$(MACH)-libassuan.depend
GNUPTH_MANIFEST = manifest-$(MACH)-gnupth.depend
LIBGPGERROR_MANIFEST = manifest-$(MACH)-libgpg-error.depend

DEPENDED +=	$(WS_COMPONENTS)/libassuan/build/$(LIBASSUAN_MANIFEST)
DEPENDED +=	$(WS_COMPONENTS)/gnupth/build/$(GNUPTH_MANIFEST)
DEPENDED +=	$(WS_COMPONENTS)/libgpg-error/build/$(LIBGPGERROR_MANIFEST)

#PKG_PROTO_DIRS += $(WS_COMPONENTS)/libassuan
#PKG_PROTO_DIRS += $(WS_COMPONENTS)/gnupth
#PKG_PROTO_DIRS += $(WS_COMPONENTS)/libgpg-error

build: $(BUILD_32_and_64)

install: $(INSTALL_32_and_64)

test: $(TEST_32_and_64)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk
