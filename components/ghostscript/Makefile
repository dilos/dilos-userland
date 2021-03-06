#
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

COMPONENT_NAME=         ghostscript
COMPONENT_VERSION=      9.00
COMPONENT_SRC=          $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=      $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH= sha1:96e75675efa0f00813f1608ba2c3833f4103ba19
COMPONENT_ARCHIVE_URL=  http://ghostscript.com/releases/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/ips.mk
include ../../make-rules/configure.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

# configure(1) options to use
CONFIGURE_OPTIONS +=	--with-drivers=ALL
CONFIGURE_OPTIONS +=	--with-ijs
CONFIGURE_OPTIONS +=	--without-omni
CONFIGURE_OPTIONS +=	--with-jbig2dec
CONFIGURE_OPTIONS +=	--with-jasper
CONFIGURE_OPTIONS +=	--enable-cups
CONFIGURE_OPTIONS +=	--enable-dynamic
CONFIGURE_OPTIONS +=	--disable-compile-inits
CONFIGURE_OPTIONS +=	--with-fontpath=/usr/share/ghostscript/$(COMPONENT_VERSION)/Resource:/usr/share/ghostscript/$(COMPONENT_VERSION)/Resource/Font:/usr/share/ghostscript/fonts:/usr/openwin/lib/X11/fonts/Type1:/usr/openwin/lib/X11/fonts/TrueType:/usr/openwin/lib/X11/fonts/Type3:/usr/X11/lib/X11/fonts/Type1:/usr/X11/lib/fonts/TrueType:/usr/X11/lib/X11/fonts/Type3:/usr/X11/lib/X11/fonts/Resource:/usr/X11/lib/X11/Resource/Font

# config env
CONFIGURE_ENV += LDFLAGS_SO="-G"
CONFIGURE_ENV += CUPSCONFIG=/usr/bin/cups-config

GS_VARIANT = $(BUILD_DIR)/$(MACH32)
IJS_VARIANT = $(BUILD_DIR)/$(MACH32)/ijs

VARIANTS = $(GS_VARIANT) $(IJS_VARIANT)

# autoconf - Generate configuration scripts
COMPONENT_PREP_ACTION = \
	 (cd $(@D); autoconf)

$(GS_VARIANT)/.configured: COMPONENT_PRE_CONFIGURE_ACTION = \
	($(CLONEY) $(SOURCE_DIR) $(@D))

$(GS_VARIANT)/.installed: COMPONENT_INSTALL_TARGETS += \
	install-exec install-so install-scripts install-data \
	install-contrib-extras

$(IJS_VARIANT)/.configured: COMPONENT_PRE_CONFIGURE_ACTION = \
	($(CLONEY) $(SOURCE_DIR)/ijs $(@D); \
	cd $(@D) ; $(ENV) $(CONFIGURE_ENV) ./autogen.sh )

CONFIGURE_SCRIPT = ./configure

# build gs and ijs
build: $(VARIANTS:%=%/.built)

# install gs and ijs
install: $(VARIANTS:%=%/.installed)

# empty test target
test:
	@echo "no tests available"

include ../../make-rules/depend.mk
