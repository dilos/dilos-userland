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

#
# Copyright (c) 2008, 2011, Oracle and/or its affiliates. All rights reserved.
#

unset LD_LIBRARY_PATH
PATH=/usr/bin:/usr/sbin
export PATH

. /usr/lib/brand/shared/common.ksh

PROP_PARENT="org.opensolaris.libbe:parentbe"
PROP_ACTIVE="org.opensolaris.libbe:active"

f_incompat_options=$(gettext "cannot specify both %s and %s options")
f_sanity_detail=$(gettext  "Missing %s at %s")
f_sanity_sparse=$(gettext  "Is this a sparse zone image?  The image must be whole-root.")
sanity_ok=$(gettext     "  Sanity Check: Passed.  Looks like an OpenSolaris system.")
sanity_fail=$(gettext   "  Sanity Check: FAILED (see log for details).")
sanity_fail_vers=$(gettext  "  Sanity Check: the Solaris image (release %s) is not an OpenSolaris image and cannot be installed in this type of branded zone.")
install_fail=$(gettext  "        Result: *** Installation FAILED ***")
f_zfs_in_root=$(gettext "Installing a zone inside of the root pool's 'ROOT' dataset is unsupported.")
f_zfs_create=$(gettext "Unable to create the zone's ZFS dataset.")
f_root_create=$(gettext "Unable to create the zone's ZFS dataset mountpoint.")
f_no_gzbe=$(gettext "unable to determine global zone boot environment.")
f_no_ds=$(gettext "the zonepath must be a ZFS dataset.\nThe parent directory of the zonepath must be a ZFS dataset so that the\nzonepath ZFS dataset can be created properly.")
f_multiple_ds=$(gettext "multiple active datasets.")
f_no_active_ds=$(gettext "no active dataset.")
f_zfs_unmount=$(gettext "Unable to unmount the zone's root ZFS dataset (%s).\nIs there a global zone process inside the zone root?\nThe current zone boot environment will remain mounted.\n")
f_zfs_mount=$(gettext "Unable to mount the zone's ZFS dataset.")

f_safedir=$(gettext "Expected %s to be a directory.")
f_cp=$(gettext "Failed to cp %s %s.")
f_cp_unsafe=$(gettext "Failed to safely copy %s to %s.")

m_brnd_usage=$(gettext "brand-specific usage: ")

v_unconfig=$(gettext "Performing zone sys-unconfig")
e_unconfig=$(gettext "sys-unconfig failed")
v_mounting=$(gettext "Mounting the zone")
e_badmount=$(gettext "Zone mount failed")
v_unmount=$(gettext "Unmounting zone")
e_badunmount=$(gettext "Zone unmount failed")
e_exitfail=$(gettext "Postprocessing failed.")

m_complete=$(gettext    "        Done: Installation completed in %s seconds.")
m_postnote=$(gettext    "  Next Steps: Boot the zone, then log into the zone console (zlogin -C)")
m_postnote2=$(gettext "              to complete the configuration process.")

fail_incomplete() {
	printf "ERROR: " 1>&2
	printf "$@" 1>&2
	printf "\n" 1>&2
	exit $ZONE_SUBPROC_NOTCOMPLETE
}

fail_usage() {
	printf "$@" 1>&2
	printf "\n" 1>&2
	printf "$m_brnd_usage" 1>&2
	printf "$m_usage\n" 1>&2
	exit $ZONE_SUBPROC_USAGE
}

is_brand_labeled() {
	if [ -z $ALTROOT ]; then
		AR_OPTIONS=""
	else
		AR_OPTIONS="-R $ALTROOT"
	fi
	brand=$(/usr/sbin/zoneadm $AR_OPTIONS -z $ZONENAME \
		list -p | awk -F: '{print $6}')
	[[ $brand == "labeled" ]] && return 1
	return 0
}

sanity_check() {
	typeset dir="$1"
	shift
	res=0

	#
	# Check for some required directories and make sure this isn't a
	# sparse zone image from SXCE.
	#
	checks="etc etc/svc var var/svc"
	for x in $checks; do
		if [[ ! -e $dir/$x ]]; then
			log "$f_sanity_detail" "$x" "$dir"
			res=1
		fi
	done
	if (( $res != 0 )); then
		log "$f_sanity_sparse"
		log "$sanity_fail"
		fatal "$install_fail" "$ZONENAME"
	fi

	#
	# XXX There should be a better way to do this.
	# Check image release.  We only work on the same minor release as the
	# system is running.  The INST_RELEASE file doesn't exist with IPS on
	# OpenSolaris, so its presence means we have an earlier Solaris
	# (i.e. non-OpenSolaris) image.
	#
	if [[ -f "$dir/var/sadm/system/admin/INST_RELEASE" ]]; then
		image_vers=$(nawk -F= '{if ($1 == "VERSION") print $2}' \
		    $dir/var/sadm/system/admin/INST_RELEASE)
		vlog "$sanity_fail_vers" "$image_vers"
		fatal "$install_fail" "$ZONENAME"
	fi
	
	vlog "$sanity_ok"
}

get_current_gzbe() {
	#
	# If there is no alternate root (normal case) then set the
	# global zone boot environment by finding the boot environment
	# that is active now.
	# If a zone exists in a boot environment mounted on an alternate root,
	# then find the boot environment where the alternate root is mounted.
	#
	if [ -x /usr/sbin/beadm ]; then
		CURRENT_GZBE=`/usr/sbin/beadm list -H | /usr/bin/nawk \
				-v alt=$ALTROOT -F\; '{
			if (length(alt) == 0) {
			    # Field 3 is the BE status.  'N' is the active BE.
			    if ($3 !~ "N")
				next
			} else {
			    # Field 4 is the BE mountpoint.
			    if ($4 != alt)
				next
			}
			# Field 2 is the BE UUID
			print $2
		}'`
	else
		# If there is no beadm command then the system doesn't really
		# support multiple boot environments.  We still want zones to
		# work so simulate the existence of a single boot environment.
		CURRENT_GZBE="opensolaris"
	fi

	if [ -z "$CURRENT_GZBE" ]; then
		fail_fatal "$f_no_gzbe"
	fi
}

# Find the active dataset under the zonepath dataset to mount on zonepath/root.
# $1 CURRENT_GZBE
# $2 ZONEPATH_DS
get_active_ds() {
	ACTIVE_DS=`/usr/sbin/zfs list -H -r -t filesystem \
	    -o name,$PROP_PARENT,$PROP_ACTIVE $2/ROOT | \
	    /usr/bin/nawk -v gzbe=$1 ' {
		if ($1 ~ /ROOT\/[^\/]+$/ && $2 == gzbe && $3 == "on") {
			print $1
			if (found == 1)
				exit 1
			found = 1
		}
	    }'`

	if [ $? -ne 0 ]; then
		fail_fatal "$f_multiple_ds"
	fi

	if [ -z "$ACTIVE_DS" ]; then
		fail_fatal "$f_no_active_ds"
	fi
}

# Check that zone is not in the ROOT dataset.
fail_zonepath_in_rootds() {
	case $1 in
		rpool/ROOT/*)
			fail_fatal "$f_zfs_in_root"
			break;
			;;
		*)
			break;
			;;
	esac
}

#
# Make sure the active dataset is mounted for the zone.  There are several
# cases to consider:
# 1) First boot of the zone, nothing is mounted
# 2) Zone is halting, active dataset remains the same.
# 3) Zone is halting, there is a new active dataset to mount.
#
mount_active_ds() {
	mount -p | cut -d' ' -f3 | egrep -s "^$ZONEPATH/root$"
	if (( $? == 0 )); then
		# Umount current dataset on the root (it might be an old BE).
		umount $ZONEPATH/root
		if (( $? != 0 )); then
			# The umount failed, leave the old BE mounted.
			# Warn about gz process preventing umount.
			printf "$f_zfs_unmount" "$ZONEPATH/root"
			return
		fi
	fi

	# Mount active dataset on the root.
	get_current_gzbe
	get_zonepath_ds $ZONEPATH
	get_active_ds $CURRENT_GZBE $ZONEPATH_DS

	mount -F zfs $ACTIVE_DS $ZONEPATH/root || fail_fatal "$f_zfs_mount"
}

#
# Set up ZFS dataset hierarchy for the zone root dataset.
#
create_active_ds() {
	get_current_gzbe

	#
	# Find the zone's current dataset.  This should have been created by
	# zoneadm.
	#
	get_zonepath_ds $zonepath

	# Check that zone is not in the ROOT dataset.
	fail_zonepath_in_rootds $ZONEPATH_DS

	#
	# From here on, errors should cause the zone to be incomplete.
	#
	int_code=$ZONE_SUBPROC_FATAL

	#
	# We need to tolerate errors while creating the datasets and making the
	# mountpoint, since these could already exist from some other BE.
	#

	/usr/sbin/zfs list -H -o name $ZONEPATH_DS/ROOT >/dev/null 2>&1
	if (( $? != 0 )); then
		/usr/sbin/zfs create -o mountpoint=legacy \
		    -o zoned=on $ZONEPATH_DS/ROOT
		if (( $? != 0 )); then
			fail_fatal "$f_zfs_create"
		fi
	fi

	BENAME=zbe
	BENUM=0
	# Try 100 different names before giving up.
	while [ $BENUM -lt 100 ]; do
       		/usr/sbin/zfs create -o $PROP_ACTIVE=on \
		    -o $PROP_PARENT=$CURRENT_GZBE \
		    -o canmount=noauto $ZONEPATH_DS/ROOT/$BENAME >/dev/null 2>&1
		if (( $? == 0 )); then
			break
		fi
		BENUM=`expr $BENUM + 1`
		BENAME="zbe-$BENUM"
	done

	if [ $BENUM -ge 100 ]; then
		fail_fatal "$f_zfs_create"
	fi

	if [ ! -d $ZONEROOT ]; then
		/usr/bin/mkdir -p $ZONEROOT
	fi

	/usr/sbin/mount -F zfs $ZONEPATH_DS/ROOT/$BENAME $ZONEROOT || \
	    fail_incomplete "$f_zfs_mount"
}

#
# Run sys-unconfig on the zone.
#
unconfigure_zone() {
	vlog "$v_unconfig"

	vlog "$v_mounting"
	ZONE_IS_MOUNTED=1
	zoneadm -z $ZONENAME mount -f || fatal "$e_badmount"

	zlogin -S $ZONENAME /usr/sbin/sys-unconfig -R /a \
	    </dev/null >/dev/null 2>&1
	if (( $? != 0 )); then
		error "$e_unconfig"
		failed=1
	fi

	vlog "$v_unmount"
	zoneadm -z $ZONENAME unmount || fatal "$e_badunmount"
	ZONE_IS_MOUNTED=0

	[[ -n $failed ]] && fatal "$e_exitfail"
}

#
# Handle pkg exit code.  Exit 0 means Command succeeded, exit 4 means
# No changes were made - nothing to do.  Any other exit code is an error.
#
pkg_err_check() {
	typeset res=$?
	(( $res != 0 && $res != 4 )) && fail_fatal "$1"
}

### DPKG ###
get_depends ()
{
    typeset PACKAGES="$*"
    typeset DEPS=
    DEPS=`apt-cache depends $PACKAGES | grep Depends | nawk '{print $2}'`
    DEPS=`echo "$DEPS" | sed -e "s;<libapt-pkg4\.10>;;" | sort -u`
    echo "$DEPS"
}

apt_download ()
{
    typeset PACKAGES="$*"
    typeset APTCACHE=
    APTCACHE=$ZONEROOT/var/cache/apt
    env ZONEINST=1 apt-get -d -o=dir::cache=$APTCACHE update
    env ZONEINST=1 apt-get -d -o=dir::cache=$APTCACHE -y --force-yes --reinstall install $PACKAGES
}

get_file ()
{
    typeset PKG="$1"
    typeset FILE=
    typeset PKGFILE=
    FILE=$PKG"_*.deb"
    PKGFILE=`find $ZONEROOT/var/cache/apt/archives -name "$FILE"`
    echo "$PKGFILE"
}

dpkg_unpack ()
{
    typeset PKG=$1
    typeset TO=
    typeset FILE=
    TO=$ZONEROOT
    FILE=`get_file $PKG`
    echo "Unpacking $PKG to $TO ..."
    env ZONEINST=1 dpkg-deb -x $FILE $TO
}

dpkg_inst ()
{
    typeset PKG=$1
    typeset FILE=
    FILE=`get_file $PKG | sed -e "s;$ZONEROOT;;"`
    echo "Installing $PKG ..."
#    echo "== $ZONEROOT"
#    echo "/usr/gnu/bin/chroot $ZONEROOT dpkg --force-all -i $FILE"
    /usr/gnu/bin/chroot $ZONEROOT env ZONEINST=1 dpkg --force-all -i $FILE
}

dpkg_init ()
{
    typeset TARGET=$ZONEROOT
    mkdir -p $TARGET/var/lib/dpkg/updates
    mkdir -p $TARGET/var/lib/dpkg/info
    mkdir -p $TARGET/var/lib/dpkg/alien
    mkdir -p $TARGET/var/lib/dpkg/alternatives
    mkdir -p $TARGET/var/lib/dpkg/parts
    mkdir -p $TARGET/var/lib/dpkg/triggers

    touch $TARGET/var/lib/dpkg/status
    touch $TARGET/var/lib/dpkg/available

    mkdir -p $TARGET/var/cache/apt
#    mkdir -p $TARGET/kernel
#    mkdir -p $TARGET/platform
}

apt_mount ()
{
    /usr/gnu/bin/chroot $ZONEROOT mount -F proc /proc
#    mount -F lofs /dev/pts $ZONEROOT/dev/pts
}

apt_umount ()
{
#    umount $ZONEROOT/dev/pts
    chroot $ZONEROOT umount /proc 2> /dev/null 1>&2
}
