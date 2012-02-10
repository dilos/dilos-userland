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

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

include ../common.mk

COMPONENT_PRE_CONFIGURE_ACTION = ( \
	($(CLONEY) $(SOURCE_DIR) $(@D)); \
	$(GSED) -e "s@^builddir=.*@builddir=$(BUILD_DIR_32)@" \
		< $(COMPONENT_DIR)/../php-sapi/phpize-proto \
		> $(COMPONENT_DIR)/phpize-proto; \
	cd $(BUILD_DIR_32); \
	$(ENV) -i $(ENVLINE) $(CONFIG_SHELL) $(COMPONENT_DIR)/phpize-proto)


CONFIGURE_OPTIONS  += \
	--with-php-config=$(COMPONENT_DIR)/../php-sapi/php-config-proto

CONFIGURE_ENV += $(ENVLINE)
CONFIGURE_SCRIPT = $(BUILD_DIR_32)/configure
CPPFLAGS += -I$(PHP_SAPI_BUILD)/Zend
CPPFLAGS += -I$(PHP_SAPI_BUILD)/TSRM
CPPFLAGS += -I$(PHP_SAPI_BUILD)/main

CLEAN_PATHS += $(COMPONENT_DIR)/phpize-proto package.xml package2.xml tmp

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(TEST_32)

# Manual dependency - to build any extension requires php-sapi to be installed
../php-sapi/build/$(MACH32)/.installed:
	(cd ../php-sapi ; $(MAKE) install)

$(BUILD_DIR_32)/.configured:	../php-sapi/build/$(MACH32)/.installed

# Manual dependency
# Need $(COMPONENT_NAME)-zts installed before $(COMPONENT_NAME) publish
../$(COMPONENT_NAME)-zts/build/$(MACH32)/.installed:
	(cd ../$(COMPONENT_NAME)-zts ; $(MAKE) install)

$(INSTALL_32):	../$(COMPONENT_NAME)-zts/build/$(MACH32)/.installed

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
