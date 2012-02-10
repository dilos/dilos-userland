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

COMPONENT_NAME=		apr-util
COMPONENT_VERSION=	1.3.9
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:fd2a76352353e6bc2f7cc7da80e2ab3842795199
COMPONENT_ARCHIVE_URL=	http://archive.apache.org/dist/apr/$(COMPONENT_ARCHIVE)

CONFIGURE_DEFAULT_DIRS=no

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include ../../make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

CC += $(CC_BITS)
CXX += $(CC_BITS)

PATCH_LEVEL=0

APR_DIR = $(WS_COMPONENTS)/apr/build/prototype/$(MACH)

#LDFLAGS.32 += -L$(APR_DIR)/usr/apr/1.3/lib
#LDFLAGS.64 += -L$(APR_DIR)/usr/apr/1.3/lib/$(MACH64)

CFLAGS += -DSSL_EXPERIMENTAL -DSSL_ENGINE
#CPPFLAGS += -I$(WS_COMPONENTS)/mysql-5-1/build/prototype/$(MACH)/usr/mysql/5.1/include/mysql
#LDFLAGS.32 = -L$(WS_COMPONENTS)/mysql-5-1/build/prototype/$(MACH)/usr/mysql/5.1/lib/mysql
#LDFLAGS.64 = -L$(WS_COMPONENTS)/mysql-5-1/build/prototype/$(MACH)/usr/mysql/5.1/lib/$(MACH64)/mysql

#CONFIGURE_ENV += CPPFLAGS="$(CPPFLAGS)"
#CONFIGURE_ENV += LDFLAGS="$(LDFLAGS)"

CONFIGURE_PREFIX = /usr/apr-util/1.3

CONFIGURE_OPTIONS +=		--with-mysql=/usr/mysql/5.1
CONFIGURE_OPTIONS +=		--with-expat=/usr
CONFIGURE_OPTIONS +=		--with-sqlite3=/usr
CONFIGURE_OPTIONS +=		--with-ldap=ldap
CONFIGURE_OPTIONS +=		--without-odbc
#CONFIGURE_OPTIONS +=	CFLAGS="$(CFLAGS) -DSSL_EXPERIMENTAL -DSSL_ENGINE"
CONFIGURE_OPTIONS +=		LTFLAGS="--tag=CC --silent"
CONFIGURE_OPTIONS.32 +=		--enable-layout=OpenSolaris
CONFIGURE_OPTIONS.64 +=		--enable-layout=OpenSolaris-$(MACH64)

CONFIGURE_OPTIONS.32 +=		--with-apr=/usr/apr/1.3/bin/apr-1-config
CONFIGURE_OPTIONS.64 +=		--with-apr=/usr/apr/1.3/bin/$(MACH64)/apr-1-config

#CONFIGURE_OPTIONS +=		--with-apr=$(APR_DIR)/usr/apr/1.3
#CONFIGURE_OPTIONS.32 +=		--with-apr=$(APR_DIR)/usr/apr/1.3/bin/apr-1-config
#CONFIGURE_OPTIONS.64 +=		--with-apr=$(APR_DIR)/usr/apr/1.3/bin/$(MACH64)/apr-1-config

CONFIGURE_OPTIONS.64 +=		MYSQL_CONFIG=/usr/mysql/5.1/bin/$(MACH64)/mysql_config
#CONFIGURE_OPTIONS.32 +=	MYSQL_CONFIG=$(WS_COMPONENTS)/mysql-5-1/build/prototype/$(MACH)/usr/mysql/5.1/bin/mysql_config
#CONFIGURE_OPTIONS.64 +=	MYSQL_CONFIG=$(WS_COMPONENTS)/mysql-5-1/build/prototype/$(MACH)/usr/mysql/5.1/bin/$(MACH64)/mysql_config
#CONFIGURE_OPTIONS +=	--with-mysql=$(WS_COMPONENTS)/mysql-5-1/build/prototype/$(MACH)/usr/mysql/5.1
#CONFIGURE_OPTIONS +=	--with-mysql
#CONFIGURE_OPTIONS += 		mysql_CPPFLAGS="$(CPPFLAGS)"
#CONFIGURE_OPTIONS += 		mysql_LDFLAGS="$(LDFLAGS)"

#PATH=$(SPRO_VROOT)/bin:/usr/bin:/usr/gnu/bin
PATH=$(GCC_ROOT)/bin:/usr/bin:/usr/gnu/bin
COMPONENT_BUILD_ENV += PATH="$(PATH)"
#COMPONENT_BUILD_ENV += mysql_CPPFLAGS="$(CPPFLAGS)"
#COMPONENT_BUILD_ENV += mysql_LDFLAGS="$(LDFLAGS)"

COMPONENT_TEST_TARGETS= test

# We need this to keep doxygen happy (for include/ and docs/ contents).
COMPONENT_PRE_CONFIGURE_ACTION += ($(CLONEY) $(SOURCE_DIR) $(@D));

# Some patches need configure script recreation.
COMPONENT_PRE_CONFIGURE_ACTION += (cd $(@D); autoconf);

# Documentation is generated in and directly packaged from 32 bit build
# directory using doxygen.
PKG_PROTO_DIRS += $(BUILD_DIR)/$(MACH32)/docs/dox/html

docs: $(BUILD_DIR)/$(MACH32)/.built
	cd $(BUILD_DIR)/$(MACH32); doxygen docs/doxygen.conf

build: $(BUILD_32_and_64) docs

install: $(INSTALL_32_and_64)

test: $(TEST_32_and_64)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
