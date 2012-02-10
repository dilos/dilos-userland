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
# Copyright (c) 2012, Adam 'xenol' Stevko <adam.stevko@gmail.com> 
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		zabbix-agent
COMPONENT_VERSION=	1.8.10
COMPONENT_SRC=		zabbix-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	zabbix-$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:3d36413b9bd04da66775e9255243242d205a7e9c
COMPONENT_PROJECT_URL=	http://www.zabbix.com/
COMPONENT_ARCHIVE_URL=	http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)/download

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk
include ../../make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER=		gcc

COMPONENT_PRE_CONFIGURE_ACTION = \
	($(CLONEY) $(SOURCE_DIR) $(@D))

# Ugly hack for fixing problems with missing files in source directory
CONFIGURE_SCRIPT=	$(BUILD_DIR_$(BITS))/configure

CONFIGURE_OPTIONS +=	--enable-ipv6
CONFIGURE_OPTIONS +=	--enable-agent


build:          $(BUILD_32)

install:        $(INSTALL_32)

test:           $(TESTS_32)
