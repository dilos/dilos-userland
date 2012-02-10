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
# Copyright (c) 2012, Igor Kozhukhov, Inc. All rights reserved.
#
include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=         dpkg-brand-zone
COMPONENT_VERSION=      1.0
#COMPONENT_SRC=          $(COMPONENT_NAME)-$(COMPONENT_VERSION)
#COMPONENT_ARCHIVE=      $(COMPONENT_SRC).tar.gz
#COMPONENT_ARCHIVE_HASH= sha1:c2037aa9fa9915b9182faa46b01ed9e81f0cfbdd
#COMPONENT_ARCHIVE_URL=  http://www.dilos.org/srcarch/$(COMPONENT_ARCHIVE)

# set relocate_to option while unpacking the tar ball
#UNPACK_ARGS= -r $(COMPONENT_SRC)

#include ../../make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

download prep build:
	@echo "nothing to be done for $@"

install: 
	$(MKDIR) $(PROTO_DIR)
	$(CP) -r src/* $(PROTO_DIR)

test:	$(NO_TESTS)

clean::
	$(RM) -r $(BUILD_DIR)

include $(WS_TOP)/make-rules/depend.mk
