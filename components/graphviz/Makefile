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

COMPONENT_NAME=		graphviz
COMPONENT_VERSION=	2.28.0
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:4725d88a13e071ee22e632de551d4a55ca08ee7d
COMPONENT_ARCHIVE_URL=	http://www.graphviz.org/pub/graphviz/stable/SOURCES/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include ../../make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

PKGMOGRIFY_TRANSFORMS +=	$(WS_TOP)/transforms/libtool-drop

PATH =		$(GCC_ROOT)/bin:/usr/bin:/usr/gnu/bin:/usr/php/5.2/bin

# GMP header files for the guile extension (no --with- flag)
# The guile build is broken with studio (7073649), so we disable this for now.
# CPPFLAGS +=	-I/usr/include/gmp
# Java header files (--with-javaincludedir allows for only one directory)
CPPFLAGS +=	-I/usr/java/include -I/usr/java/include/solaris
# PHP header files (no --with- flag)
CPPFLAGS +=	$(shell PATH=$(PATH) php-config --includes)
CXX +=		$($(COMPILER)_NORUNPATH)

#CONFIGURE_ENV +=	CPPFLAGS="$(CPPFLAGS)"
#CONFIGURE_ENV +=	PERL=$(PERL)
CONFIGURE_OPTIONS +=	--without-included-ltdl
CONFIGURE_OPTIONS +=	--enable-python=no
CONFIGURE_OPTIONS +=	--enable-python26=yes

COMPONENT_BUILD_ARGS += 	GREP="$(GREP)"

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)
	$(ENV) LD_LIBRARY_PATH="$(PROTO_DIR)/usr/lib" GVBINDIR="$(PROTO_DIR)/usr/lib/graphviz" $(PROTO_DIR)/usr/bin/dot -c
	$(PYTHON.2.6.32) -m compileall $(PROTO_DIR)/usr/lib/graphviz/python26

# The test infrastructure doesn't run in a VPATHed environment.
COMPONENT_PRE_TEST_ACTION = \
	(cd $(@D)/rtest; ln -s $(SOURCE_DIR)/rtest/* .)

# There are tests, but they fail consistently because the test samples are out
# of date and not generated with a known configuration.  See
# http://graphviz.org/bugs/b2063.html
test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)
