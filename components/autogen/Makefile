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

COMPONENT_NAME=		autogen
COMPONENT_VERSION=	5.9
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:00510cd07be7a35591bac7bf1f6f78bf607d193d
COMPONENT_ARCHIVE_URL=	http://ftp.gnu.org/gnu/autogen/rel$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

# build target is incorrect without this 
COMPONENT_PRE_CONFIGURE_ACTION =        ($(CLONEY) $(SOURCE_DIR) $(@D))

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

# strip the environment or install target fails
ENV +=	-i

#CPPFLAGS += -I$(WS_COMPONENTS)/gnump/build/prototype/$(MACH)/usr/include/gmp
#CPPFLAGS += -I$(WS_COMPONENTS)/guile/build/prototype/$(MACH)/usr/include

#LDFLAGS += -L$(WS_COMPONENTS)/gnump/build/prototype/$(MACH)/usr/lib
#LDFLAGS += -L$(WS_COMPONENTS)/guile/build/prototype/$(MACH)/usr/lib

#CONFIGURE_ENV += CPPFLAGS="$(CPPFLAGS)"
#CONFIGURE_ENV += LDFLAGS="$(LDFLAGS)"

#CONFIGURE_OPTIONS  +=	--with-libguile=$(WS_COMPONENTS)/guile/build/prototype/$(MACH)/usr
#CONFIGURE_OPTIONS  +=	--with-pic


GUILE_MANIFEST = 	manifest-$(MACH)-guile.depend
DEPENDED +=		$(WS_COMPONENTS)/guile/build/$(GUILE_MANIFEST)

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(TEST_32)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
