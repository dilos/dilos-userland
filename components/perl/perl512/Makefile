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

# I want to override PERL_VERSION and PERL_ARCH because when building
# a new version of perl it probably isn't installed so shared-macros.mk
# can't call it.

COMPONENT_NAME=		perl
COMPONENT_VERSION=	5.12.4
PERL_VERSION=		5.12
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH=	sha1:68ff2f4a0901d1e4ea263f452001db0563d2edb3
COMPONENT_ARCHIVE_URL=	http://www.cpan.org/src/5.0/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/justmake.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk
include ../Makefile.common

#
# Override these compiler settings because they are causing problems
# in the ON build of the contrib components.
# ON doesn't use or need these settings or the compiler has some of them
# on by default.
# This also produces a perl more inline with past perl's.  For better
# or worse.
#
#studio_XBITS=
#studio_XREGS=
#studio_IROPTS=
#studio_C99MODE=
#studio_ALIGN=
#studio_MT=

#
# The extra Configure parameters (cf_email, cf_by, myhostname) and
# the gawk and sed that follow are attempting to sanatize the
# resulting config.sh of values from our build environment that
# are discoverable in perl's config via "perl -V".
# I'm assuming our compilers live on a path that contains "SUNWspro".
# If that changes the sed filter needs to change.
#

COMPONENT_PRE_BUILD_ACTION= \
	(cd $(@D); $(ENV) -i \
		MAKE=$(GMAKE) \
		PATH=$(GCC_ROOT)/bin:$(PATH) \
		$(CONFIG_SHELL) ./Configure \
			    -Dprefix=/usr/perl5/$(PERL_VERSION) \
			    -Dprivlib=/usr/perl5/$(PERL_VERSION)/lib \
			    -Dsitelib=/usr/perl5/site_perl/$(PERL_VERSION) \
			    -Dvendorprefix=/usr/perl5/$(PERL_VERSION) \
			    -Dvendorlib=/usr/perl5/vendor_perl/$(PERL_VERSION) \
			    -Dlibperl=libperl.so.$(PERL_VERSION) \
			    -Duseshrplib \
			    -Dusedtrace \
			    -Duse64bitint \
			    -Dcc="$(CC) -B/usr/ccs/bin/" \
			    -Accflags="-fno-stack-protector" \
			    -Doptimize="$(CFLAGS)" \
			    -Dcf_email="perl-bugs@sun.com" \
			    -Dcf_by="perl-bugs" \
			    -Dmyhostname="localhost" \
			    -O \
			    -de ) ; \
	(cd $(@D); \
	    cp config.sh config.sh_orig ; \
	    gawk \
	    '/^myuname=/{print $$1" localhost "$$3" "$$5" "$$6" "$$7"\047"} ; \
	    		!/^myuname=/ {print}' config.sh_orig \
		| \
		sed -e 's/[^ ]*SUNWspro[^ ]*//g' > config.sh )


COMPONENT_INSTALL_ENV	+=	DESTDIR="$(PROTO_DIR)"
#
# perl's install path for sparc is based off the value of the
# "arch" command.  So we must package that way also.
#
PKG_MACROS		+=	PERL_ARCH=$(shell arch)
PKG_MACROS		+=	PERL_VERSION=$(PERL_VERSION)
#
# Put studio compilers in PATH so we can tell Configure and gmake just
# use cc.  Trying to avoid the full path so it doesn't end up in
# perl's config.
#
LD_OPTIONS= 
COMPONENT_BUILD_ENV	+=	PATH=$(GCC_ROOT)/bin:$(PATH)
COMPONENT_BUILD_ENV	+=	LD_OPTIONS=$(LD_OPTIONS)
COMPONENT_INSTALL_ENV	+=	LD_OPTIONS=$(LD_OPTIONS)

build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(TEST_32)
	#
	# 2 expected failures because of the use of cloney in this build.
	# Without cloney all tests pass.
	#

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
