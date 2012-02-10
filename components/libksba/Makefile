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

COMPONENT_NAME=		libksba
COMPONENT_VERSION=	1.1.0
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL=	http://www.gnupg.org/related_software/libksba/
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH=	sha1:984e5ecc1ffd62f329c200bc9d0416022f1c4f5b
COMPONENT_ARCHIVE_URL=	ftp://ftp.gnupg.org/gcrypt/libksba/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

CFLAGS += $(CPP_LARGEFILES)

LIBGPGERR_DIR = $(WS_COMPONENTS)/libgpg-error/build/prototype/$(MACH)

LDFLAGS.32 += -L$(LIBGPGERR_DIR)/usr/lib
LDFLAGS.64 += -L$(LIBGPGERR_DIR)/usr/lib/$(MACH64)

CONFIGURE_OPTIONS  +=		--localstatedir=/var
CONFIGURE_OPTIONS  +=		--infodir=$(CONFIGURE_INFODIR)
CONFIGURE_OPTIONS  +=		--enable-shared
CONFIGURE_OPTIONS  +=		--disable-static
#CONFIGURE_OPTIONS  +=		--with-gpg-error-prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS  +=		--with-gpg-error-prefix=$(LIBGPGERR_DIR)/usr
CONFIGURE_OPTIONS  +=		--with-pic

build: $(BUILD_32_and_64)

install: $(INSTALL_32_and_64)

COMPONENT_POST_INSTALL_ACTION = \
	($(RM) $(PROTO_DIR)/usr/lib/*.la \
		$(PROTO_DIR)/usr/lib/$(MACH64)/*.la)

test: $(TEST_32_and_64)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk

