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

COMPONENT_PRE_INSTALL_ACTION += ( \
	$(MKDIR) $(INSTALL_ROOT)/$(PHP_PEAR_CACHE_DIR) )

COMPONENT_POST_UNPACK_ACTION += ( \
	echo $(PATH); \
	cp /usr/include/zlib.h $(COMPONENT_SRC)/ext/zlib/my_zlib.h )

COMPONENT_PRE_CONFIGURE_ACTION = ( \
	cd $(COMPONENT_SRC); $(ENV) -i PATH=$(GCC_ROOT)/bin:/usr/gnu/bin:$(PATH) \
		MAKE="$(GMAKE)" \
		$(CONFIG_SHELL) ./buildconf --force ; \
	$(MV) configure configure.orig; \
	$(GSED) -e "s\#-i -a -n php5\#-i -n php5\#" \
		< configure.orig > configure; \
	$(CHMOD) 755 configure; \
	$(CLONEY) $(SOURCE_DIR) $(@D) )
