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

COMPONENT_NAME=		zip
COMPONENT_VERSION=	3.0
COMPONENT_SRC=		$(COMPONENT_NAME)30
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tgz
COMPONENT_ARCHIVE_HASH=	sha1:c9f4099ecf2772b53c2dd4a8e508064ce015d182
COMPONENT_ARCHIVE_URL=	ftp://ftp.info-zip.org/pub/infozip/src/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/justmake.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

# remove the unwanted file.
COMPONENT_PREP_ACTION = rm -f $(SOURCE_DIR)/match.S

COMPONENT_BUILD_ENV += CC="$(CC)"

# The Makefile we want is under unix/Makefile
COMPONENT_BUILD_ARGS += -f unix/Makefile
COMPONENT_BUILD_TARGETS += generic
COMPONENT_INSTALL_ARGS += -f unix/Makefile

# This doesn't respect DESTDIR, so overload BINDIR and MANDIR when we install.
COMPONENT_INSTALL_ARGS += BINDIR=$(PROTOUSRBINDIR)
COMPONENT_INSTALL_ARGS += MANDIR=$(PROTOUSRSHAREMAN1DIR)

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk


