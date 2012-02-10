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
# Copyright (c) 2012, Igor Kozhukhov. All rights reserved.
#
include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		reprepro
COMPONENT_VERSION=	4.9.0
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_NAME)_$(COMPONENT_VERSION).orig.tar.gz
COMPONENT_ARCHIVE_URL=	http://alioth.debian.org/frs/download.php/3697/$(COMPONENT_ARCHIVE)
COMPONENT_ARCHIVE_HASH=	sha1:2717a1c7142ab1109f978e09e8231760bfc82e71

#WS_DEBS = $(shell pwd)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

CFLAGS += $(CPP_LARGEFILES)
CFLAGS += -Wall -g -Wextra -Wmissing-prototypes -Wstrict-prototypes

BDB_DIR = $(WS_COMPONENTS)/berkeleydb/build/prototype/$(MACH)
GPGME_DIR = $(WS_COMPONENTS)/gpgme/build/prototype/$(MACH)
LIBARCHIVE_DIR = $(COMPONENT_DIR)/libarchive/build/prototype/$(MACH)

CPPFLAGS += -I$(LIBARCHIVE_DIR)/usr/include
CPPFLAGS += -I$(BDB_DIR)/usr/include
LDFLAGS += -L$(LIBARCHIVE_DIR)/usr/lib
LDFLAGS += -L$(BDB_DIR)/usr/lib

CONFIGURE_OPTIONS +=	--mandir=$(CONFIGURE_MANDIR)
CONFIGURE_OPTIONS +=	--infodir=$(CONFIGURE_INFODIR)
CONFIGURE_OPTIONS +=	--enable-largefile
CONFIGURE_OPTIONS +=	--with-libbz2
CONFIGURE_OPTIONS +=	--with-libgpgme=$(GPGME_DIR)/usr
#CONFIGURE_OPTIONS +=	--without-libarchive
CONFIGURE_OPTIONS +=	--with-static-libarchive=$(LIBARCHIVE_DIR)/usr/lib/libarchive.a

$(BUILD_DIR_32)/.configured: $(LIBARCHIVE_DIR)/usr/lib/libarchive.a \
				$(BDB_DIR)/usr/lib/libdb-5.1.so

GPGME_MANIFEST = manifest-$(MACH)-gpgme.depend
DEPENDED +=	$(WS_COMPONENTS)/gpgme/build/$(GPGME_MANIFEST)
BDB_MANIFEST = manifest-$(MACH)-berkeleydb.depend
DEPENDED +=	$(WS_COMPONENTS)/berkeleydb/build/$(BDB_MANIFEST)

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

$(LIBARCHIVE_DIR)/usr/lib/libarchive.a:
	$(MAKE) -C $(COMPONENT_DIR)/libarchive install

$(BDB_DIR)/usr/lib/libdb-5.1.so:
	$(MAKE) -C $(WS_COMPONENTS)/berkeleydb install

clean::
	$(MAKE) -C $(COMPONENT_DIR)/libarchive clean

clobber::
	$(MAKE) -C $(COMPONENT_DIR)/libarchive clobber

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

test: $(TEST_32)

include $(WS_TOP)/make-rules/depend.mk
