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

COMPONENT_NAME=		unrar
COMPONENT_VERSION=	3.8.5
COMPONENT_SRC=		$(COMPONENT_NAME)
COMPONENT_PROJECT_URL=	http://www.rarlabs.com/rar_add.htm
COMPONENT_ARCHIVE=	$(COMPONENT_NAME)src-$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:911d3ef2c279d9522afa22b452176dd86883a751
COMPONENT_ARCHIVE_URL=	http://www.rarlab.com/rar/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/justmake.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

#PATH=$(SPRO_VROOT)/bin:/usr/bin:/usr/gnu/bin:/usr/sbin
PATH=$(GCC_ROOT)/bin:/usr/bin:/usr/gnu/bin:/usr/sbin
COMPONENT_BUILD_ENV += PATH="$(PATH)"

PKG_PROTO_DIRS = $(MANGLED_DIR)
PKG_PROTO_DIRS += $(BUILD_DIR_32)
PKG_PROTO_DIRS += $(COMPONENT_DIR)

PATCH_LEVEL = 0

CXXFLAGS += $(CFLAGS)
CXXFLAGS += -erroff=wvarhidemem
CXXFLAGS.i386 += -DLITTLE_ENDIAN
CXXFLAGS.sparc += -DBIG_ENDIAN
CXXFLAGS += $(CXXFLAGS.$(MACH))

COMPONENT_BUILD_ENV += CXX="$(CXX)"
COMPONENT_BUILD_ENV += CXXFLAGS="$(CXXFLAGS)"
COMPONENT_BUILD_ENV += LDFLAGS="$(LDFLAGS)"
COMPONENT_BUILD_ENV += DEFINES="$(CPP_LARGEFILES)"

COMPONENT_BUILD_ARGS += -f makefile.unix

# common targets
build:		$(BUILD_32)

install:	$(BUILD_32)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
