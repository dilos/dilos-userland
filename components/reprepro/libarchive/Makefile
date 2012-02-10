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
# Copyright (c) 2011, Igor Kozhukhov. All rights reserved.
#
include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		libarchive
COMPONENT_VERSION=	2.8.5
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_NAME)_$(COMPONENT_VERSION).orig.tar.gz
COMPONENT_ARCHIVE_URL=	http://ftp.de.debian.org/debian/pool/main/liba/libarchive/$(COMPONENT_ARCHIVE)
COMPONENT_ARCHIVE_HASH=	sha1:e48a3b50de84b1d747f5af9ca5ba90eb6d3a4a78

#WS_DEBS = $(shell pwd)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

CFLAGS += $(CPP_LARGEFILES)
#CFLAGS += -Wall -g -Wextra -Wmissing-prototypes -Wstrict-prototypes

#CPPFLAGS = -I/myshare/builds/dilos/bdb/dbd32/usr/include
#LDFLAGS += -L/myshare/builds/dilos/bdb/dbd32/usr/lib

#GPGME_DIR = $(WS_COMPONENTS)/gpgme/build/prototype/$(MACH)

CONFIGURE_OPTIONS +=	--mandir=$(CONFIGURE_MANDIR)
CONFIGURE_OPTIONS +=	--infodir=$(CONFIGURE_INFODIR)
CONFIGURE_OPTIONS +=	--enable-largefile
CONFIGURE_OPTIONS +=	--enable-bsdtar=static
CONFIGURE_OPTIONS +=	--enable-bsdcpio=static
CONFIGURE_OPTIONS +=	--enable-static
CONFIGURE_OPTIONS +=	--disable-shared
CONFIGURE_OPTIONS +=	--with-pic

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

test: $(TEST_32)

include $(WS_TOP)/make-rules/depend.mk
