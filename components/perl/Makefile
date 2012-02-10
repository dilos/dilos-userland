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
include ../../make-rules/shared-macros.mk
include ../../make-rules/ips.mk
include ../../make-rules/deb.mk

# for now, everything with a Makefile should be built
SUBDIRS = mod_DBI \
	mod_net-ssleay \
	mod_pmtools \
	mod_xml-parser \
	mod_xml-simple \
	perl512 \
	perl_defaults

.PHONY:	$(SUBDIRS)

download:		TARGET = download
prep:			TARGET = prep
install:		TARGET = install
clean:			TARGET = clean
clobber:		TARGET = clobber
test:			TARGET = test
publish:		TARGET = publish
deb:			TARGET = deb

build:		$(BUILD_DIR)

install:	build

.DEFAULT:	publish

#download prep install test publish deb: $(SUBDIRS)
clean clobber publish deb: $(SUBDIRS)

$(SUBDIRS):	FORCE
	@cd $@ && echo "$(TARGET) $@" && $(MAKE) $(TARGET)

# declare module dependencies
mod_DBI:	perl512
mod_net-ssleay:	perl512
mod_pmtools:	perl512
mod_xml-parser:	perl512
mod_xml-simple:	mod_xml-parser
mod_timedate:	perl512
perl_defaults:	perl512

FORCE:
