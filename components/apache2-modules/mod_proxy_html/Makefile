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
include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		mod_proxy_html
COMPONENT_VERSION=	3.1.1
COMPONENT_SRC=		$(COMPONENT_NAME)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC)-$(COMPONENT_VERSION).tar.bz2
COMPONENT_ARCHIVE_HASH=	sha1:d36398151994f308ce36bacab09beb8165bf01a7
# Original archive from community didn't contain name in its version.
# Therefore we created special Userland copy with version info.
COMPONENT_ARCHIVE_URL=	http://apache.webthing.com/mod_proxy_html/$(COMPONENT_ARCHIVE)

include ../../../make-rules/prep.mk
include ../../../make-rules/justmake.mk
include ../../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

APACHE_USR_PREFIX=/usr/apache2/2.2

$(BUILD_DIR_32)/.built: COMPONENT_BUILD_ARGS +=	APXS=$(APACHE_USR_PREFIX)/bin/apxs
$(BUILD_DIR_64)/.built: COMPONENT_BUILD_ARGS +=	APXS=$(APACHE_USR_PREFIX)/bin/$(MACH64)/apxs

COMPONENT_BUILD_ARGS += LTFLAGS="--tag=CC --silent"

#PATH=$(SPRO_VROOT)/bin:/usr/bin:/usr/gnu/bin
PATH=$(GCC_ROOT)/bin:/usr/bin:/usr/gnu/bin
COMPONENT_BUILD_ENV += PATH=$(PATH)

build: $(BUILD_32_and_64)

test: $(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../../make-rules/depend.mk
