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
# Copyright (c) 2012, Igor Kozhukhov. All rights reserved.
#

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		perl
COMPONENT_VERSION=	1.0

include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

PERL512_MANIFEST =	manifest-$(MACH)-perl-512.depend

# Work around pkgdepend bug which doesn't resolve dependencies from
# the local workspace repo. Fortunately we only have to do this once.
DEPENDED +=	$(WS_COMPONENTS)/perl/perl512/build/$(PERL512_MANIFEST)

download prep build install:
	@echo "nothing to be done for $@"

$(BUILD_DIR):
	$(MKDIR) $@

clobber clean:
	$(RM) -r $(BUILD_DIR)
	$(RM) *.log
