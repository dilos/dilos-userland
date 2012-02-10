# DEB makefile

#DEB_VERSION ?= 1.0.11-6
#DEB_VERSION ?= $(BUILD_NUM).0-2
#WS_DEBS =	$(WS_TOP)/$(MACH)/debs.$(DEB_VERSION)

PKGS=$(CANONICAL_MANIFESTS:%.p5m=$(BUILD_DIR)/%.deb_stamp)

IPS2DEB = $(WS_TOOLS)/ips2deb.pl

DEB_PKG_NAME = $(shell cat $< | grep "set name=pkg.fmri" | sed -e 's/.*pkg:\///' | sed -e 's/\@.*//' | sed -e 's/[\/_]/-/g')

BUILD_DEB = \
	cd $(BUILD_DIR)/debs/$(DEB_PKG_NAME) ; \
	PATH=/usr/gnu/bin:/usr/bin:/sbin:/usr/sbin \
	BASEGATE="$(BUILD_DIR)/prototype/$(MACH)" \
	DEB_BUILD_OPTIONS=nocheck /usr/bin/dpkg-buildpackage -d -b -uc 2> build.log 1>&2

MFEXT ?= 	mangled
PKGTYPE = 	userland

deb:	$(BUILD_DIR) build install $(BUILD_DIR)/debs $(PKGS)

$(BUILD_DIR)/%.deb_stamp: $(MANIFEST_BASE)-%.mangled
	(BASEGATE="$(BUILD_DIR)/prototype/$(MACH)" \
	MANIFESTGATE="$(BUILD_DIR)" \
	DESTINATION="$(BUILD_DIR)/debs" \
	PKGVER="$(DEB_VERSION)" \
	MFEXT=$(MFEXT) \
	PKGTYPE=$(PKGTYPE) \
	    $(IPS2DEB) -p $< \
	     $(PKG_PROTO_DIRS:%=-d %))
	-$(COMPONENT_PRE_DEB_ACTION)
	($(BUILD_DEB) && \
	    $(MV) $(BUILD_DIR)/debs/*.deb $(BUILD_DIR)/debs/*.changes $(WS_DEBS)/)
	-$(COMPONENT_POST_DEB_ACTION)

	touch $@

$(BUILD_DIR)/debs:
	$(MKDIR) $@

deb-clean:
	$(RM) $(PKGS)
	$(RM) $(COMPONENT_DIR)/*.deb
	$(RM) $(COMPONENT_DIR)/*.changes
