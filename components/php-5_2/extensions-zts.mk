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

# NOTE: this phpize-proto comes from nsapi while
#       php-config-proto comes from sapi
COMPONENT_PRE_CONFIGURE_ACTION = ( \
	($(CLONEY) $(SOURCE_DIR) $(@D)); \
	$(GSED) -e "s@^builddir=.*@builddir=$(BUILD_DIR_32)@" \
		< $(WS_COMPONENTS)/php-5_2/php-nsapi/phpize-proto.zts \
		> $(COMPONENT_DIR)/phpize-proto.zts; \
	cd $(BUILD_DIR_32); \
	$(ENV) -i $(ZTS_ENVLINE) $(CONFIG_SHELL) \
					$(COMPONENT_DIR)/phpize-proto.zts)


CONFIGURE_OPTIONS  += \
	--with-php-config=$(WS_COMPONENTS)/php-5_2/php-sapi/php-config-proto.zts

CONFIGURE_ENV += $(ZTS_ENVLINE)
CONFIGURE_SCRIPT = $(BUILD_DIR_32)/configure
CPPFLAGS += -I$(PHP_SAPI_BUILD)/Zend
CPPFLAGS += -I$(PHP_SAPI_BUILD)/TSRM
CPPFLAGS += -I$(PHP_SAPI_BUILD)/main

CLEAN_PATHS += $(COMPONENT_DIR)/phpize-proto.zts package.xml package2.xml

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(TEST_32)

publish:	install

# Manual dependency - need both php-sapi and php-nsapi installed
# before building a -zts extension.
$(WS_COMPONENTS)/php-5_2/php-sapi/build/$(MACH32)/.installed:
	(cd $(WS_COMPONENTS)/php-5_2/php-sapi ; $(MAKE) install)

$(WS_COMPONENTS)/php-5_2/php-nsapi/build/$(MACH32)/.installed:
	(cd $(WS_COMPONENTS)/php-5_2/php-nsapi ; $(MAKE) install)

$(BUILD_DIR_32)/.configured:    $(WS_COMPONENTS)/php-5_2/php-sapi/build/$(MACH32)/.installed
$(BUILD_DIR_32)/.configured:    $(WS_COMPONENTS)/php-5_2/php-nsapi/build/$(MACH32)/.installed

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
