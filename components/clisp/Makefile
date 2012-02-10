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

CONFIGURE_DEFAULT_CPPFLAGS = no
include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		clisp
COMPONENT_VERSION=	2.47
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL=	http://clisp.cons.org/
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH=	sha1:63749bf07409cee134c195547e6d911554b619d6
COMPONENT_ARCHIVE_URL=	http://ftp.gnu.org/gnu/clisp/release/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)

# we have problems with -j more then 1
# we need JOBS=1 for this component
DEF_JOBS := no

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT=	/usr/gcc/4.4
COMPILER=	gcc
PATCH_LEVEL=	0

LD_MAP_PAGEALIGN=

# Required to configure correctly.
COMPONENT_PRE_CONFIGURE_ACTION = \
	($(CLONEY) $(SOURCE_DIR) $(@D))

# SHELLOPTS appears to cause clisp's configure script to fail while
# checking the compiler.
unexport SHELLOPTS

LIBSIGSEGV_DIR = $(WS_COMPONENTS)/libsigsegv/build/prototype/$(MACH)
READLINE_DIR = $(WS_COMPONENTS)/readline/build/prototype/$(MACH)

LDFLAGS.32 += -L$(LIBSIGSEGV_DIR)/usr/lib
LDFLAGS.64 += -L$(LIBSIGSEGV_DIR)/usr/lib/$(MACH64)

LDFLAGS.32 += -L$(READLINE_DIR)/usr/lib
LDFLAGS.64 += -L$(READLINE_DIR)/usr/lib/$(MACH64)

# clisp's configure script is not a GNU auto* tools generated configure script
# and doesn't take --sbindir, so we need to override the default values.
CONFIGURE_OPTIONS = --prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS += --mandir=$(CONFIGURE_MANDIR)
CONFIGURE_OPTIONS += --bindir=$(CONFIGURE_BINDIR.$(BITS))
CONFIGURE_OPTIONS += --libdir=$(CONFIGURE_LIBDIR.$(BITS))
CONFIGURE_OPTIONS += --srcdir=$(SOURCE_DIR)
CONFIGURE_OPTIONS += --disable-rpath
#CONFIGURE_OPTIONS += --with-libsigsegv-prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS += --with-libsigsegv-prefix=$(LIBSIGSEGV_DIR)/usr
#CONFIGURE_OPTIONS += --with-libreadline-prefix=$(CONFIGURE_PREFIX)
CONFIGURE_OPTIONS += --with-libreadline-prefix=$(READLINE_DIR)/usr

COMPONENT_BUILD_ENV += LDFLAGS="$(LDFLAGS)"
#COMPONENT_BUILD_ENV += LD_LIBRARY_PATH="$(GCC_ROOT)/lib/$(BITS):$$LD_LIBRARY_PATH"

READLINE_LIBS.32 = $(READLINE_DIR)/usr/lib
READLINE_LIBS.64 = $(READLINE_DIR)/usr/lib/$(MACH64)
READLINE_LIBS = $(READLINE_LIBS.$(BITS))

LIBSIGSEGV_LIBS.32 = $(LIBSIGSEGV_DIR)/usr/lib
LIBSIGSEGV_LIBS.64 = $(LIBSIGSEGV_DIR)/usr/lib/$(MACH64)
LIBSIGSEGV_LIBS = $(LIBSIGSEGV_LIBS.$(BITS))

COMPONENT_INSTALL_ENV += LD_LIBRARY_PATH="$(READLINE_LIBS):$(LIBSIGSEGV_LIBS):$$LD_LIBRARY_PATH"

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(TEST_32)

tst:
	echo $(BUILD_JOBS) $(DEF_JOBS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
