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

COMPONENT_NAME=		mpc
COMPONENT_VERSION=	0.9
COMPONENT_PROJECT_URL=	http://www.multiprecision.org/
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:229722d553030734d49731844abfef7617b64f1a
COMPONENT_ARCHIVE_URL=	$(COMPONENT_PROJECT_URL)mpc/download/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include ../../make-rules/deb.mk

export SHELL
SHELL=/bin/sh

GMP_DIR = $(WS_COMPONENTS)/gnump/build/prototype/$(MACH)
MPFR_DIR = $(WS_COMPONENTS)/mpfr/build/prototype/$(MACH)

#CFLAGS +=		`pkg-config --cflags libmpfr`

CONFIGURE_OPTIONS  +=		--infodir=$(CONFIGURE_INFODIR)
#CONFIGURE_OPTIONS  +=		CFLAGS="$(CFLAGS)"
CONFIGURE_OPTIONS  +=		--disable-static
CONFIGURE_OPTIONS  +=		--with-gmp-include=$(GMP_DIR)/usr/include/gmp
CONFIGURE_OPTIONS.32  +=	--with-gmp-lib=$(GMP_DIR)/usr/lib
CONFIGURE_OPTIONS.64  +=	--with-gmp-lib=$(GMP_DIR)/usr/lib/$(MACH64)
CONFIGURE_OPTIONS  +=		--with-mpfr-include=$(MPFR_DIR)/usr/include/mpfr
CONFIGURE_OPTIONS.32  +=	--with-mpfr-lib=$(MPFR_DIR)/usr/lib
CONFIGURE_OPTIONS.64  +=	--with-mpfr-lib=$(MPFR_DIR)/usr/lib/$(MACH64)

include ../../make-rules/shared-targets.mk

# common targets
build:	$(BUILD_32_and_64)

install:	$(INSTALL_32_and_64)	

COMPONENT_POST_INSTALL_ACTION = \
	($(RM) $(PROTO_DIR)/usr/lib/*.la \
		$(PROTO_DIR)/usr/lib/$(MACH64)/*.la)

test: install
		@cd $(BUILD_DIR_32)/tests; $(MAKE) check
		@cd $(BUILD_DIR_64)/tests; $(MAKE) check
 
BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
