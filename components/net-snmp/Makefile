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

#PATH=$(SPRO_VROOT)/bin:/usr/gnu/bin:/usr/bin
DOXYGEN=/usr/bin/doxygen

COMPONENT_NAME=		net-snmp
COMPONENT_VERSION=	5.4.1
COMPONENT_PROJECT_URL=	http://www.net-snmp.org/
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH= sha1:ac5ba033c10d53d3057415121f8c4936c643c208
#COMPONENT_ARCHIVE_URL=	http://ftp.ntua.gr/mirror/net-snmp/net-snmp/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)
COMPONENT_ARCHIVE_URL= http://ftp.ntua.gr/mirror/net-snmp/OldFiles/net-snmp-5.4.x/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)

# we have problems with -j more then 1
# we need JOBS=1 for this component
DEF_JOBS := no

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

GCC_ROOT = /usr/gcc/4.4
COMPILER = gcc

PATH=$(dir $(CC)):/usr/gnu/bin:/usr/bin

#CFLAGS += $(studio_C99_ENABLE)
CPPFLAGS += "-DFALSE_SHARING_ALIGN=64"

CONFIGURE_OPTIONS  +=	--with-default-snmp-version=3
CONFIGURE_OPTIONS  +=	--with-sys-contact="root@localhost"
CONFIGURE_OPTIONS  +=	--with-sys-location=Unknown
CONFIGURE_OPTIONS  +=	--with-logfile=/var/log/snmpd.log
CONFIGURE_OPTIONS  +=	--with-persistent-directory=/var/net-snmp

CONFIGURE_OPTIONS  +=	--with-mibdirs=/etc/net-snmp/snmp/mibs
CONFIGURE_OPTIONS  +=	--datadir=/etc/net-snmp
CONFIGURE_OPTIONS  +=	--enable-agentx-dom-sock-only
CONFIGURE_OPTIONS  +=	--enable-ucd-snmp-compatibility
CONFIGURE_OPTIONS  +=	--enable-ipv6
CONFIGURE_OPTIONS  +=	--enable-mfd-rewrites
CONFIGURE_OPTIONS  +=	--with-pkcs
CONFIGURE_OPTIONS  +=	--with-transports="UDP TCP UDPIPv6 TCPIPv6"

# Which MIB modules do we want to build
MIB_MOBULES.sparc = ucd-snmp/lmSensors
MIB_MODULES = host disman/event-mib ucd-snmp/diskio udp-mib tcp-mib if-mib
MIB_MOBULES += $(MIB_MODULES.$(MACH))
CONFIGURE_OPTIONS  +=	--with-mib-modules="$(MIB_MODULES)"

# Only build 32 bit Perl support
PERL_ARGS =			DESTDIR=$(PROTO_DIR) INSTALLDIRS=vendor
CONFIGURE_OPTIONS.32  +=	PERLPROG="$(PERL)"
CONFIGURE_OPTIONS.32  +=	--with-perl-modules="$(PERL_ARGS)"
CONFIGURE_OPTIONS.32  +=	--disable-perl-cc-checks

CONFIGURE_OPTIONS.64  +=	--disable-embedded-perl
CONFIGURE_OPTIONS.64  +=	--without-perl-modules

#CONFIGURE_OPTIONS	+=	CFLAGS="$(CFLAGS)"
CONFIGURE_OPTIONS	+=	CPPFLAGS="$(CPPFLAGS)"
#CONFIGURE_OPTIONS	+=	CC="$(CC)"

PKG_MACROS +=	BUILD_DIR=$(BUILD_DIR)

COMPONENT_PRE_CONFIGURE_ACTION = \
	($(CLONEY) $(SOURCE_DIR) $(@D); $(CLONEY) $(COMPONENT_DIR)/sun $(@D)/sun)

# for the goofy definition of ARCH in the extra Makefiles
ARCH=32
ARCH=$(BITS:64=$(MACH64))

SUN_ROOT32 = $(PROTO_DIR)
SUN_ROOT64 = $(BUILD_DIR)/prototype/$(MACH64)

CCSMAKE_ARGS =	CC="$(CC) $(CC_BITS)" CFGPREFIX=/usr CFGLIB64=/usr/lib/$(MACH64)
CCSMAKE_ARGS +=	CFGLIB=/usr/lib ARCH=$(ARCH) ROOT=$(SUN_ROOT$(BITS))

#CCSMAKE_ARGS =	CC="$(CC)" CFGPREFIX=/usr CFGLIB64=/usr/lib/$(MACH64)
#CCSMAKE_ARGS +=	CFGLIB=/usr/lib ARCH=$(ARCH) ROOT=$(PROTO_DIR)

$(BUILD_32): COMPONENT_POST_BUILD_ACTION= \
	(cd $(BUILD_DIR)/$(MACH32)/sun ; ls agent; $(CCSMAKE) -e $(CCSMAKE_ARGS))

$(BUILD_64): COMPONENT_POST_BUILD_ACTION= \
	(cd $(BUILD_DIR)/$(MACH64)/sun ; ls agent; $(CCSMAKE) -e $(CCSMAKE_ARGS))

$(INSTALL_32): COMPONENT_POST_INSTALL_ACTION= \
	($(MKDIR) -p $(BUILD_DIR)/prototype/$(MACH)/etc/net-snmp/snmp/mibs; \
	 cd $(BUILD_DIR)/$(MACH32)/sun ; ls agent; $(CCSMAKE) -e $(CCSMAKE_ARGS) install)

$(INSTALL_64): COMPONENT_POST_INSTALL_ACTION= \
	($(MKDIR) -p $(BUILD_DIR)/prototype/$(MACH64)/etc/net-snmp/snmp/mibs; \
	 cd $(BUILD_DIR)/$(MACH64)/sun ; ls agent; $(CCSMAKE) -e $(CCSMAKE_ARGS) install)

# common targets
build:	$(BUILD_32_and_64) $(BUILD_DIR_32)/.docs

$(INSTALL_64): COMPONENT_INSTALL_ARGS += DESTDIR=$(BUILD_DIR)/prototype/$(MACH64)

install:	build $(INSTALL_32_and_64)

test:	$(BUILD_32)
	$(KSH93) ./run-tests $(BUILD_DIR) $(MACH32) $(MACH64)

# build the docs
$(BUILD_DIR_32)/.docs:
	(cd $(@D) ; $(ENV) srcdir=$(@D) $(DOXYGEN) -u $(@D)/doxygen.conf ; \
	    $(ENV) srcdir=$(@D) $(DOXYGEN) $(@D)/doxygen.conf)
	$(TOUCH) $@
