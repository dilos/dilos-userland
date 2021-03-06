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

COMPONENT_NAME=		nethack
COMPONENT_VERSION=	3.4.3
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_NAME)-343-src.tgz
COMPONENT_ARCHIVE_HASH=	sha1:c26537093c38152bc0fbcec20468d975b35f59fd
COMPONENT_ARCHIVE_URL=	http://sourceforge.net/projects/$(COMPONENT_NAME)/files/$(COMPONENT_NAME)/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)/download

include ../../make-rules/prep.mk
include ../../make-rules/justmake.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

PATCH_LEVEL=0

# Need to use Makefiles in the sys/unix directory and copy them into various
# other directories.
#
COMPONENT_PREP_ACTION= (cd $(SOURCE_DIR)/sys/unix ; sh setup.sh)

COMPONENT_INSTALL_ARGS += CHOWN=true
COMPONENT_INSTALL_ARGS += CHGRP=true
COMPONENT_INSTALL_ARGS += ROOT=$(PROTO_DIR)

PKG_PROTO_DIRS += $(COMPONENT_SRC)/doc

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)
	sed -e 's/^!\(NetHack.tomb\)/\1/' -e 's/^!\(NetHack.pet\)/\1/' \
		-e 's/^!\(NetHack.tile_file\)/\1/' \
		$(COMPONENT_SRC)/win/X11/NetHack.ad \
		> $(PROTO_DIR)/usr/lib/nethack/NetHack.ad

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
