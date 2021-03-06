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

COMPONENT_NAME=		libassuan
COMPONENT_VERSION=	2.0.2
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL=	http://www.gnupg.org/related_software/libassuan/
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH=	sha1:dbcd96e2525d4c3a2da9e8054a06fa517f20a185
COMPONENT_ARCHIVE_URL=	ftp://ftp.gnupg.org/gcrypt/libassuan/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

LIBGPGERR_DIR = $(WS_COMPONENTS)/libgpg-error/build/prototype/$(MACH)

# Enable C99 mode + -Xc for its additional warnings.
#studio_C99MODE = -Xc $(studio_C99_ENABLE)

# -xinline=%auto -- we like inlining where appropriate
#CFLAGS += -xinline=%auto

# -xbuiltin=%none -- builtins have been known to be buggy
#CFLAGS += -xbuiltin=%none

CFLAGS += $(CPP_LARGEFILES)
#CFLAGS += $(XPG6MODE)
#CFLAGS += $(CPP_POSIX)
#CFLAGS += $(CPP_C99_EXTENDED_MATH)
#CFLAGS += $(studio_PIC)

LDFLAGS.32 += -L$(LIBGPGERR_DIR)/usr/lib
LDFLAGS.64 += -L$(LIBGPGERR_DIR)/usr/lib/$(MACH64)
LDFLAGS += $(LDFLAGS.$(BITS))

#CONFIGURE_ENV +=	CFLAGS="$(CFLAGS)"
#CONFIGURE_ENV +=	INSTALL="$(INSTALL)"
CONFIGURE_ENV +=	LDFLAGS="$(LDFLAGS)"

CONFIGURE_OPTIONS  +=		--localstatedir=/var
CONFIGURE_OPTIONS  +=		--infodir=$(CONFIGURE_INFODIR)
CONFIGURE_OPTIONS  +=		--enable-shared
CONFIGURE_OPTIONS  +=		--disable-static
#CONFIGURE_OPTIONS  +=		--with-gpg-error-prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-gpg-error-prefix=$(LIBGPGERR_DIR)/usr
CONFIGURE_OPTIONS  +=		--with-pic
#CONFIGURE_OPTIONS  +=		LDFLAGS="$(LDFLAGS)"

build: $(BUILD_32_and_64)

install: $(INSTALL_32_and_64)

COMPONENT_POST_INSTALL_ACTION = \
	($(RM) $(PROTO_DIR)/usr/lib/*.la \
		$(PROTO_DIR)/usr/lib/$(MACH64)/*.la)

test: $(TEST_32_and_64)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk

