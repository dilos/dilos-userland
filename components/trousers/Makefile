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

COMPONENT_NAME=		trousers
COMPONENT_VERSION=	0.3.6
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_PROJECT_URL=	http://sourceforge.net/projects/trousers/files/trousers/
COMPONENT_ARCHIVE_HASH=	sha1:1bb65fe1a031f9606d871562ead35fa5909ae584
COMPONENT_ARCHIVE_URL=	$(COMPONENT_PROJECT_URL)$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include ../../make-rules/lint-libraries.mk
include ../../make-rules/deb.mk

#GCC_ROOT = /usr/gcc/4.4
#COMPILER = gcc

PATCH_LEVEL=0

LIBS = -lnsl -lsocket -lgen

CFLAGS += -DSOLARIS -DBI_OPENSSL -D_REENTRANT

CONFIGURE_OPTIONS += --with-gui=openssl
#CONFIGURE_OPTIONS += CC="$(CC)"
CONFIGURE_OPTIONS += LD="$(CC)"
#CONFIGURE_OPTIONS += CFLAGS="$(CFLAGS)"
#CONFIGURE_OPTIONS += LDFLAGS="$(LDFLAGS)"
CONFIGURE_OPTIONS += LIBS="$(LIBS)"

COMPONENT_POST_CONFIGURE_ACTION = (cd $(COMPONENT_SRC); \
	for f in `ls src/include/tss/*.h` ; do \
		/usr/bin/dos2unix $$f $$f; \
	done; \
	for f in `ls src/include/trousers/*.h` ; do \
		/usr/bin/dos2unix $$f $$f; \
	done; \
	for f in `ls src/include/*.h` ; do \
		/usr/bin/dos2unix $$f $$f; \
	done; \
	/usr/bin/libtoolize -f; \
	$(ACLOCAL); \
	$(AUTOMAKE) src/tspi/Makefile; \
	$(AUTOCONF))	

#
# We had to use cc as the linker (see CONFIGURE_OPTIONS above) so the 
# .init and .fini sections get set correctly.  Because we use cc, we 
# must pass the -m64 flag through cc to the linker when building 64 bit 
# libraries.  We can't just add it to LDFLAGS because then it gets used 
# when creating executables and static libs and generates lots of noise 
# in the build logs.  LDARCHFLAG is only recognized by the Makefile in 
# the src/tspi directory.
#
COMPONENT_BUILD_ENV.64 += LDARCHFLAG="-Wl,$(CC_BITS)"

COMPONENT_TEST_TARGETS = 

COMPONENT_BUILD_TARGETS = all

# common targets
build:		$(BUILD_32_and_64)

install:	$(INSTALL_32_and_64)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
