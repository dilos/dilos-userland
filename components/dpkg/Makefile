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
#
include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		dpkg
#COMPONENT_VERSION=	1.15.8.10
COMPONENT_VERSION=	1.15.8.11
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_NAME)_$(COMPONENT_VERSION).tar.bz2
#COMPONENT_ARCHIVE_URL=	http://dpkg.sourcearchive.com/downloads/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)
COMPONENT_ARCHIVE_URL=	http://ftp.de.debian.org/debian/pool/main/d/$(COMPONENT_NAME)/$(COMPONENT_ARCHIVE)
#COMPONENT_ARCHIVE_HASH=	sha1:a150b97ec47996bf8f01d6bc14d41587faa4bbff
COMPONENT_ARCHIVE_HASH=	sha1:c5ed99e6617a7e5ab9c8b30e159c09fcfd9fa5c9

#WS_DEBS = $(shell pwd)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include ../../make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

CFLAGS += -Wall -Wextra -Wno-unused-parameter
CFLAGS += $(CPP_LARGEFILES)
CXXFLAGS += -Wall -Wextra -Wno-unused-parameter
CXXFLAGS += $(CPP_LARGEFILES)
#CFLAGS += -g -O2 $(WFLAGS)
#CXXFLAGS += -g -O2 $(WFLAGS)
CPPFLAGS += -I/usr/include/ncurses

#CONFIGURE_ENV +=	LDFLAGS="$(LDFLAGS)"
#CONFIGURE_ENV +=	CXXFLAGS="$(CXXFLAGS)"
#CONFIGURE_ENV +=	CPPFLAGS="$(CPPFLAGS)"

CONFIGURE_OPTIONS +=	--mandir=$(CONFIGURE_MANDIR)
CONFIGURE_OPTIONS +=	--infodir=$(CONFIGURE_INFODIR)
CONFIGURE_OPTIONS +=	--sysconfdir=/etc
CONFIGURE_OPTIONS +=	--localstatedir=/var
CONFIGURE_OPTIONS +=	--with-zlib
CONFIGURE_OPTIONS +=	--with-bz2
CONFIGURE_OPTIONS +=	--disable-linker-optimisations
CONFIGURE_OPTIONS +=	--without-install-info
CONFIGURE_OPTIONS +=	--enable-largefile
CONFIGURE_OPTIONS +=	--disable-rpath

#CONFIGURE_OPTIONS +=	CFLAGS="$(CFLAGS)"
#CONFIGURE_OPTIONS +=	CXXFLAGS="$(CXXFLAGS)"
#CONFIGURE_OPTIONS +=	CPPFLAGS="$(CPPFLAGS)"
#CONFIGURE_OPTIONS +=	LDFLAGS="$(LDFLAGS)"

COMPONENT_BUILD_ENV +=	DEB_BUILD_OPTIONS=nocheck

COMPONENT_PRE_DEB_ACTION = \
	@(for f in preinst postinst prerm postrm; do \
		[ -f $(DEB_PKG_NAME).$$f ] && $(CP) $(DEB_PKG_NAME).$$f \
			$(BUILD_DIR)/debs/$(DEB_PKG_NAME)/debian/ ; \
	done)

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

test: $(TEST_32)

include ../../make-rules/depend.mk
