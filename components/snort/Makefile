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

#
# Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		snort
COMPONENT_VERSION=	2.8.4.1
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:3ffabb5366c088952fefab19a8dc19ce84d62645
COMPONENT_PROJECT_URL=	http://www.snort.org/
# the main site does not retain older releases
COMPONENT_ARCHIVE_URL=	http://mirror2.openwrt.org/sources/$(COMPONENT_ARCHIVE)

# we have problems with -j more then 1
# we need JOBS=1 for this component
DEF_JOBS := no

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

PATCH_LEVEL =	0

# without this we bus error on sparc. sadly I don't see any patches
# that might relate from the upstream (though maybe that's really
# "happily", as this is simpler)
#studio_ALIGN.sparc.32=	-xmemalign=1i

CONFIGURE_OPTIONS +=	--with-libpcre=included
CONFIGURE_OPTIONS +=	--with-libpcap=/usr
CONFIGURE_OPTIONS +=	--enable-static=no
#CONFIGURE_OPTIONS +=	CFLAGS="$(CFLAGS)"

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
