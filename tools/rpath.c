/*
 * CDDL HEADER START
 *
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License (the "License").
 * You may not use this file except in compliance with the License.
 *
 * You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
 * or http://www.opensolaris.org/os/licensing.
 * See the License for the specific language governing permissions
 * and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL HEADER in each
 * file and include the License file at usr/src/OPENSOLARIS.LICENSE.
 * If applicable, add the following below this CDDL HEADER, with the
 * fields enclosed by brackets "[]" replaced with your own identifying
 * information: Portions Copyright [yyyy] [name of copyright owner]
 *
 * CDDL HEADER END
 */

/*
 * Copyright 2007 Sun Microsystems, Inc.  All rights reserved.
 * Use is subject to license terms.
 */
#pragma ident	"@(#)rpath.c	1.4	 07/07/02 SMI"


/*
 *					Ali Bahrami, Sun Microsystems, Inc.
 *					Ali<dot>Bahrami<at>Sun<dot>COM
 *
 * Get or set the runpath of a Solaris dynamic object:
 *
 *	% rpath [-dr] file [path]
 *
 * where:
 *
 *	file - File to be processed
 *	path - A new runpath string
 *
 *	[-d] - Cause detailed ELF information about the data found
 *		and the changes being made to be written to stderr.
 *	[-r] - Instead of adding or modifying the runpath, completely
 *		remove any runpath from the file. If -r is specified,
 *		the path argument is not allowed.
 *
 * If the path argument is not present, the current runpath, if any,
 * is printed to stdout, and the file is not modified. In this case,
 * only read access is required.
 *
 * If the path argument is supplied, rpath will modify the file to
 * have the specified runpath, if possible. The file must be writable
 * in this case. Not all files can be modified:
 *
 *	- The desired string must already exist in the dynamic string
 *		table, or there must be enough room in the reserved
 *		section at the end (DT_SUNW_STRPAD) for the new
 *		string to be added.
 *
 *	- The dynamic section must already have a DT_RPATH or DT_RUNPATH
 *		element, or there must be an extra DT_NULL slot at the
 *		end where a DT_RUNPATH can be inserted.
 *
 * Historically, ELF objects have not had the room necessary to add
 * a string or a dynamic element to an existing file, and changes of
 * this nature have not been possible. This changed in Solaris with
 * the integration of
 *
 *	PSARC 2007/127 Reserved space for editing ELF dynamic sections
 *	6516118 Reserved space needed in ELF dynamic section and string table
 *
 * in Nevada (proto Solaris 11) build 61.
 *
 * Please note that the amount of space available for adding new strings
 * is fairily small, and that each added string consumes some of it.
 * It may still not be possible to add an extremely long runpath to a
 * file. We strongly recommend that you consider the use of the $ORIGIN
 * token for your runpath, as described in the ld and ld.so.1 manpages,
 * and the Linkers and Libraries Guide.
 */


#include	<stdio.h>
#include	<stdarg.h>
#include	<stdlib.h>
#include	<unistd.h>
#include	<errno.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#include	<fcntl.h>
#include	<string.h>
#include	<strings.h>
#include	<libelf.h>
#include	<gelf.h>



static int d_flg;		/* -d command line option */
static int r_flg;		/* -r command line option */
static const char *file;	/* File being processed */

/*
 * Structure used to cache section information
 */
typedef struct {
	GElf_Word	c_ndx;		/* Section index */
	GElf_Shdr	c_shdr;
	Elf_Data	*c_data;
	char		*c_name;
} Cache;

/*
 * We use this structure to keep track of dynamic section items
 */
typedef struct {
	int		seen;		/* True if this item has been seen */
	GElf_Word	ndx;		/* Index of item in dynamic array */
	GElf_Dyn	dyn;		/* Contents of dynamic item */
} dyn_elt_t;

/*
 * Given a elfedit_dyn_elt_t variable, and a string table descriptor,
 * return the string it references.
 */
#define	DYN_ELT_STRING(_elt, _strsec) \
	(((char *)(_strsec)->c_data->d_buf) + (_elt)->dyn.d_un.d_val)



/*
 * Issue a fatal error to stderr and exit the process.
 */
/*PRINTFLIKE1*/
static void
msg_fatal(const char *format, ...)
{
	va_list args;

	va_start(args, format);
	(void) fprintf(stderr, "rpath: ");
	(void) vfprintf(stderr, format, args);
	va_end(args);

	exit(1);
}

/*
 * Issue usage message to stderr and exit the process.
 */
static void
msg_usage(void)
{
	(void) fprintf(stderr, "usage: rpath [-dr] file [runpath]\n");
	exit(1);
}

/*
 * If -d option was set, issue a debug message to stderr. Otherwise
 * no output is produced.
 */
/*PRINTFLIKE1*/
static void
msg_debug(const char *format, ...)
{
	va_list args;

	if (d_flg) {
		va_start(args, format);
		(void) fprintf(stderr, "rpath: ");
		(void) vfprintf(stderr, format, args);
		va_end(args);
	}
}

/*
 * Wrapper on msg_fatal() that issues an error that results from
 * a call to libelf.
 *
 * entry:
 *	file - Name of ELF object
 *	libelf_rtn_name - Name of routine that was called
 *
 * exit:
 *	An error has been issued that shows the routine called
 *	and the libelf error string for it from elf_errmsg().
 *	This routine does not return to the caller.
 */
static void
msg_elf(const char *libelf_rtn_name)
{
	const char *errstr = elf_errmsg(elf_errno());

	msg_fatal("%s: %s failed: %s\n", file,
	    libelf_rtn_name, errstr ? errstr : "<unknown>");
}



/*
 * Prepare an dyn_elt_t structure for use.
 */
static void
dyn_elt_init(dyn_elt_t *elt)
{
	elt->seen = 0;
}

/*
 * Given a dynamic section item, save it in the given dyn_elt_t
 * structure and mark that structure to show that it is present.
 */
static void
dyn_elt_save(dyn_elt_t *elt, GElf_Word ndx, GElf_Dyn *dyn)
{
	elt->seen = 1;
	elt->ndx = ndx;
	elt->dyn = *dyn;
}



/*
 * Returns the offset of the specified string from within
 * the given section.
 *
 * entry:
 *	sec - Descriptor for section
 *	tail_ign - If non-zero, the # of characters at the end of the
 *		section that should be ignored and not searched.
 *	str - String we are looking for.
 *	ret_offset - Address of variable to receive result
 *
 * exit:
 *	Returns 1 for success, and 0 for failure. If successful, *ret_offset
 *	is set to the offset of the found string within the section.
 */
static int
sec_findstr(Cache *sec, GElf_Word tail_ign,
    const char *str, GElf_Word *ret_offset)
{
	int		str_fch = *str;	/* First character in str */
	GElf_Word	len;		/* # characters in table */
	char		*s;		/* ptr to strings within table */
	const char	*tail;		/* 1 past final character of table */


	/* Size of the section, minus the reserved part (if any) at the end */
	len = sec->c_shdr.sh_size - tail_ign;

	/*
	 * Move through the section character by character looking for
	 * a match. Moving character by character instead of skipping
	 * from NULL terminated string to string allows us to use
	 * the tails longer strings (i.e. we want "bar", and "foobar" exists).
	 * We look at the first character manually before calling strcmp()
	 * to lower the cost of this approach.
	 */
	s = (char *)sec->c_data->d_buf;
	tail = s + len;
	for (; s <= tail; s++) {
		if ((*s == str_fch) && (strcmp(s, str) == 0)) {
			/*LINTED*/
			*ret_offset = s - (char *)sec->c_data->d_buf;
			msg_debug("[%d]%s[%d]: Found existing string in "
			    "section: %s\n", sec->c_ndx, sec->c_name,
			    *ret_offset, s);
			return (1);
		}
	}

	/* Didn't find it. Report failure */
	return (0);
}



/*
 * Returns the offset of the specified string from within
 * the given string table.
 *
 * entry:
 *	dynsec - Dynamic section descriptor
 *	strsec - Descriptor for string table associated with dynamic section
 *	dyn_strpad - DT_SUNW_STRPAD element from dynamic section
 *	str - String we are looking for.
 *
 * exit:
 *	On success, the offset of the given string within the string
 *	table is returned. If the string does not exist within the table,
 *	but there is a valid DT_SUNW_STRPAD reserved section, then we
 *	add the string, and update the dynamic section STRPAD element
 *	to reflect the space we use.
 *
 *	This routine does not return on failure.
 */
static GElf_Word
dynstr_insert(Cache *dynsec, Cache *strsec, dyn_elt_t *dyn_strpad,
    const char *str)
{
	GElf_Word	ins_off;	/* Table offset to 1st reserved byte */
	char		*s;		/* ptr to strings within table */
	GElf_Word	len;		/* Length of str inc. NULL byte */
	GElf_Word	tail_ign;	/* # reserved bytes at end of strtab */


	tail_ign = dyn_strpad->seen ? dyn_strpad->dyn.d_un.d_val : 0;

	/* Does the string already exist in the string table? */
	if (sec_findstr(strsec, tail_ign, str, &len))
		return (len);

	/*
	 * The desired string does not already exist. Do we have
	 * room to add it?
	 */
	len = strlen(str) + 1;
	if (!dyn_strpad->seen || (len > dyn_strpad->dyn.d_un.d_val))
		msg_fatal("[%d]%s: String table does not have room "
		    "to add string\n", strsec->c_shdr.sh_link,
		    strsec->c_name);


	/*
	 * We will add the string at the first byte of the reserved NULL
	 * area at the end. The DT_SUNW_STRPAD dynamic element gives us
	 * the size of that reserved space.
	 */
	ins_off = strsec->c_shdr.sh_size - tail_ign;
	s = ((char *)strsec->c_data->d_buf) + ins_off;

	/* Announce the operation */
	msg_debug("[%d]%s[%d]: Using %d/%d byes from reserved area to "
	    "add string: %s\n", strsec->c_shdr.sh_link, strsec->c_name,
	    ins_off, len, (int)dyn_strpad->dyn.d_un.d_val, str);

	/*
	 * Copy the string into the pad area at the end, and
	 * mark the data area as dirty so libelf will flush our
	 * changes to the string data.
	 */
	(void) strncpy(s, str, dyn_strpad->dyn.d_un.d_val);
	(void) elf_flagdata(strsec->c_data, ELF_C_SET, ELF_F_DIRTY);

	/* Update the DT_STRPAD dynamic entry */
	dyn_strpad->dyn.d_un.d_val -= len;
	if (gelf_update_dyn(dynsec->c_data, dyn_strpad->ndx,
	    &dyn_strpad->dyn) == 0)
		msg_elf("gelf_update_dyn");

	return (ins_off);
}




/*
 * Delete the existing runpath from the object.
 *
 * entry:
 *	dynsec - Dynamic section
 *	numdyn - # of elements in dynamic array
 *
 * exit:
 *	Returns True (1) if the dynamic section was modified, and
 *	False (0) otherwise.
 *
 * note:
 *	The way this works is that we look at each item in the
 *	dynamic section and simply remove any DT_RPATH or
 *	DT_RUNPATH entries, copying up anything following in order
 *	to fill the hole. This is all that is needed to completely
 *	remove a runpath from an object. Note that the string is left
 *	in the string table. There is no safe way to remove it, since
 *	we cannot know that it is not used by any other item in the file,
 *	and no way to track or reuse the space if we did remove it.
 *	On the plus side, this means we can always restore the old
 *	runpath without having to add a new string.
 */
static int
remove_runpath(Cache *dynsec, GElf_Word numdyn)
{
	GElf_Dyn	dyn;
	GElf_Word	ndx, cpndx;
	int		changed = 0;

	for (ndx = cpndx = 0; ndx < numdyn; ndx++) {
		if (gelf_getdyn(dynsec->c_data, ndx, &dyn) == NULL)
			msg_elf("gelf_getdyn");

		/* Skip over any runpath element */
		if ((dyn.d_tag == DT_RPATH) || (dyn.d_tag == DT_RUNPATH)) {
			msg_debug("[%d]%s[%d]: skip runpath\n",
			    dynsec->c_ndx, dynsec->c_name, ndx);
			continue;
		}

		/*
		 * If cpndx and ndx differ, it means that we
		 * have skipped over a runpath in an earlier
		 * iteration. In this case, we need to copy
		 * the item in dynamic[ndx] back to dynamic[cpndx].
		 */
		if (ndx != cpndx) {
			msg_debug("[%d]%s[%d]: copy from [%d]\n",
			    dynsec->c_ndx, dynsec->c_name, cpndx, ndx);
			if (gelf_update_dyn(dynsec->c_data, cpndx, &dyn) == 0)
				msg_elf("gelf_update_dyn");
			changed = 1;
		}

		/* Advance copy index to receive next item */
		cpndx++;
	}

	/*
	 * If we removed a runpath element, then we should zero
	 * the slots left at the end. This is not strictly
	 * necessary, since the linker should not look past the
	 * first DT_NULL, but it is good to not leave garbage
	 * lying around.
	 */
	bzero(&dyn, sizeof (dyn));	/* Note: DT_NULL is 0 */
	for (; cpndx < numdyn; cpndx++) {
		msg_debug("[%d]%s[%d]: Set to DT_NULL\n",
		    dynsec->c_ndx, dynsec->c_name, cpndx);
		if (gelf_update_dyn(dynsec->c_data, cpndx, &dyn) == 0)
			msg_elf("gelf_update_dyn");
		changed = 1;
	}

	return (changed);
}



/*
 * Add/modify the runpath for the object.
 *
 * entry:
 *	dynsec - Dynamic section
 *	numdyn - # of elements in dynamic array
 *
 * exit:
 *	Returns True (1) if the dynamic section was modified, and
 *	False (0) otherwise.
 */
static int
new_runpath(const char *runpath, Cache *dynsec, GElf_Word numdyn,
    Cache *strsec, dyn_elt_t *rpath_elt, dyn_elt_t *runpath_elt,
    dyn_elt_t *strpad_elt, dyn_elt_t *null_elt)
{
	/*  Do we have an available dynamic section entry to use? */
	if (rpath_elt->seen || runpath_elt->seen) {
		/*
		 * We have seen a DT_RPATH, or a DT_RUNPATH, or both.
		 * If all of these have the same string as the desired
		 * new value, then we don't need to alter anything and can
		 * simply return. Otherwise, we'll modify them all to have
		 * the new string (below).
		 */
		if ((!rpath_elt->seen ||
		    (strcmp(DYN_ELT_STRING(rpath_elt, strsec),
		    runpath) == 0)) &&
		    (!runpath_elt->seen ||
		    (strcmp(DYN_ELT_STRING(runpath_elt, strsec),
		    runpath) == 0))) {
			if (rpath_elt->seen)
				msg_debug("[%d]%s[%d]: Existing DT_RPATH "
				    "already has desired value\n",
				    dynsec->c_ndx,  dynsec->c_name,
				    rpath_elt->ndx);
			if (runpath_elt->seen)
				msg_debug("[%d]%s[%d]: Existing DT_RUNPATH "
				    "already has desired value\n",
				    dynsec->c_ndx,  dynsec->c_name,
				    runpath_elt->ndx);
			return (0);
		}
	} else if (!null_elt->seen || (null_elt->ndx == (numdyn - 1))) {
		/*
		 * There is no DT_RPATH or DT_RUNPATH in the dynamic array,
		 * and there are no extra DT_NULL entries that we can
		 * convert into one. We cannot proceed.
		 */
		msg_debug("[%d]%s: Dynamic section does not have room "
		    "to add a runpath\n", dynsec->c_ndx,  dynsec->c_name);
		msg_fatal("unable to add runpath to file: %s\n", file);
	}


	/* Does the string exist in the table already, or can we add it? */
	rpath_elt->dyn.d_un.d_val = runpath_elt->dyn.d_un.d_val =
	    dynstr_insert(dynsec, strsec, strpad_elt, runpath);

	/* Update DT_RPATH entry if present */
	if (rpath_elt->seen) {
		msg_debug("[%d]%s[%d]: Reusing existing DT_RPATH entry: %s\n",
		    dynsec->c_ndx, dynsec->c_name, rpath_elt->ndx,
		    DYN_ELT_STRING(rpath_elt, strsec));
		if (gelf_update_dyn(dynsec->c_data, rpath_elt->ndx,
		    &rpath_elt->dyn) == 0)
			msg_elf("gelf_update_dyn");
	}

	/*
	 * Update the DT_RUNPATH entry in the dynamic section, if present.
	 * If one is not present, and there is also no DT_RPATH, then
	 * we use a spare DT_NULL entry to create a new DT_RUNPATH.
	 */
	if (runpath_elt->seen || !rpath_elt->seen) {
		if (runpath_elt->seen) {
			msg_debug("[%d]%s[%d]: Reusing existing DT_RUNPATH "
			    "entry: %s\n", dynsec->c_ndx, dynsec->c_name,
			    runpath_elt->ndx,
			    DYN_ELT_STRING(runpath_elt, strsec));
		} else {	/* Using a spare DT_NULL entry */
			msg_debug("[%d]%s: No existing runpath to modify. "
			    "Will use extra DT_NULL in slot [%d] \n",
			    dynsec->c_ndx, dynsec->c_name, null_elt->ndx);
			runpath_elt->seen = 1;
			runpath_elt->ndx = null_elt->ndx;
			runpath_elt->dyn.d_tag = DT_RUNPATH;
			null_elt->ndx++;
		}
		if (gelf_update_dyn(dynsec->c_data, runpath_elt->ndx,
		    &runpath_elt->dyn) == 0)
			msg_elf("gelf_update_dyn");
	}

	return (1);
}



int
main(int argc, char **argv)
{
	int		c, ndx;
	int		readonly;
	int		fd;
	const char	*file;
	const char	*runpath;
	Elf		*elf;
	GElf_Ehdr	ehdr;
	size_t		shstrndx, shnum;
	Elf_Scn		*scn;
	Elf_Data	*data;
	char		*shnames = NULL;
	Cache		*cache, *_cache;
	Cache		*dynsec, *strsec;
	GElf_Word	numdyn;
	dyn_elt_t	rpath_elt;
	dyn_elt_t	runpath_elt;
	dyn_elt_t	strpad_elt;
	dyn_elt_t	flags_1_elt;
	dyn_elt_t	null_elt;
	int		changed = 0;


	opterr = 0;
	while ((c = getopt(argc, argv, "dr")) != EOF) {
		switch (c) {
		case 'd':
			d_flg = 1;
			break;

		case 'r':
			r_flg = 1;
			break;

		case '?':
			msg_usage();
		}
	}

	/*
	 * The first plain argument is the file name, and is required.
	 * The second plain argument is the runpath, and is optional.
	 * If no runpath is given, we print the current runpath to stdout
	 * and exit. If it is present, we modify the ELF file to use it.
	 */
	argc = argc - optind;
	argv += optind;
	if ((argc < 1) || (argc > 2))
		msg_usage();
	if ((argc == 2) && r_flg)
		msg_usage();

	readonly = (argc == 1) && !r_flg;
	file = argv[0];
	if (!readonly)
		runpath = argv[1];

	if ((fd = open(file, readonly ? O_RDONLY : O_RDWR)) == -1)
		msg_fatal("unable to open file: %s: %s\n",
		    file, strerror(errno));

	(void) elf_version(EV_CURRENT);
	elf = elf_begin(fd, readonly ? ELF_C_READ : ELF_C_RDWR, NULL);
	if (elf == NULL)
		msg_elf("elf_begin");

	/* We only handle standalone ELF files */
	switch (elf_kind(elf)) {
	case ELF_K_AR:
		msg_fatal("unable to edit ELF archive: %s\n", file);
		break;
	case ELF_K_ELF:
		break;
	default:
		msg_fatal("unable to edit non-ELF file: %s\n", file);
		break;
	}

	if (gelf_getehdr(elf, &ehdr) == NULL)
		msg_elf("gelf_getehdr");

	if (elf_getshnum(elf, &shnum) == 0)
		msg_elf("elf_getshnum");

	if (elf_getshstrndx(elf, &shstrndx) == 0)
		msg_elf("elf_getshstrndx");

	/*
	 * Obtain the .shstrtab data buffer to provide the required section
	 * name strings.
	 */
	if ((scn = elf_getscn(elf, shstrndx)) == NULL)
		msg_elf("elf_getscn");
	if ((data = elf_getdata(scn, NULL)) == NULL)
		msg_elf("elf_getdata");
	shnames = data->d_buf;

	/*
	 * Allocate a cache to maintain a descriptor for each section.
	 */
	if ((cache = malloc(shnum * sizeof (Cache))) == NULL)
		msg_fatal("unable to allocate section cache: %s\n",
		    strerror(errno));
	bzero(cache, sizeof (cache[0]));
	cache->c_name = "";
	_cache = cache + 1;

	/*
	 * Fill in cache with information for each section, and
	 * locate the dynamic section.
	 */
	dynsec = strsec = NULL;
	for (ndx = 1, scn = NULL; scn = elf_nextscn(elf, scn);
	    ndx++, _cache++) {
		_cache->c_ndx = ndx;
		if (gelf_getshdr(scn, &_cache->c_shdr) == NULL)
			msg_elf("gelf_getshdr");
		_cache->c_data = elf_getdata(scn, NULL);
		_cache->c_name = shnames + _cache->c_shdr.sh_name;
		if (_cache->c_shdr.sh_type == SHT_DYNAMIC) {
			dynsec = _cache;
			numdyn = dynsec->c_shdr.sh_size /
			    dynsec->c_shdr.sh_entsize;
			msg_debug("[%d]%s: dynamic section\n",
			    ndx, _cache->c_name);
		}
	}

	/*
	 * If we got a dynamic section, locate the string table.
	 * If not, we can't continue.
	 */
	if (dynsec == NULL)
		msg_fatal("file lacks a dynamic section: %s\n", file);
	strsec = &cache[dynsec->c_shdr.sh_link];
	msg_debug("[%d]%s: dynamic string table section\n",
	    strsec->c_ndx, strsec->c_name);

	/*
	 * History Lesson And Strategy:
	 *
	 * This routine handles both DT_RPATH and DT_RUNPATH entries, altering
	 * either or both if they are present.
	 *
	 * The original SYSV ABI only had DT_RPATH, and the runtime loader used
	 * it to search for things in the following order:
	 *
	 *	DT_RPATH, LD_LIBRARY_PATH, defaults
	 *
	 * Solaris did not follow this rule. Environment variables should
	 * supersede everything else, so we have always deviated from the
	 * ABI and and instead search in the order
	 *
	 *	LD_LIBRARY_PATH, DT_RPATH, defaults
	 *
	 * Other Unix variants initially followed the ABI, but in recent years
	 * realized that it was a mistake. Hence, DT_RUNPATH was invented,
	 * with the search order:
	 *
	 *	LD_LIBRARY_PATH, DT_RUNPATH, defaults
	 *
	 * So for Solaris, DT_RPATH and DT_RUNPATH mean the same thing. If both
	 * are present (which does happen), we set them both to the new
	 * value. If either one is present, we set that one. If neither is
	 * present, and we have a spare DT_NULL slot, we create a DT_RUNPATH.
	 */

	/*
	 * Examine the dynamic section to determine the index for
	 *	- DT_RPATH
	 *	- DT_RUNPATH
	 *	- DT_SUNW_STRPAD
	 *	- DT_NULL, and whether there are any extra DT_NULL slots
	 */
	dyn_elt_init(&rpath_elt);
	dyn_elt_init(&runpath_elt);
	dyn_elt_init(&strpad_elt);
	dyn_elt_init(&flags_1_elt);
	dyn_elt_init(&null_elt);
	for (ndx = 0; ndx < numdyn; ndx++) {
		GElf_Dyn	dyn;

		if (gelf_getdyn(dynsec->c_data, ndx, &dyn) == NULL)
			msg_elf("gelf_getdyn");

		switch (dyn.d_tag) {
		case DT_NULL:
			/*
			 * Remember the state of the first DT_NULL. If there
			 * are more than one (i.e. the first one is not
			 * in the final spot), and there is no runpath, then
			 * we will turn the first one into a DT_RUNPATH.
			 */
			if (!null_elt.seen) {
				dyn_elt_save(&null_elt, ndx, &dyn);
				msg_debug("[%d]%s[%d]: DT_NULL\n",
				    dynsec->c_ndx, dynsec->c_name, ndx);
			}
			break;

		case DT_RPATH:
			dyn_elt_save(&rpath_elt, ndx, &dyn);
			msg_debug("[%d]%s[%d]: DT_RPATH: %s\n",
			    dynsec->c_ndx, dynsec->c_name, ndx,
			    DYN_ELT_STRING(&rpath_elt, strsec));
			break;

		case DT_RUNPATH:
			dyn_elt_save(&runpath_elt, ndx, &dyn);
			msg_debug("[%d]%s[%d]: DT_RUNPATH: %s\n",
			    dynsec->c_ndx, dynsec->c_name, ndx,
			    DYN_ELT_STRING(&runpath_elt, strsec));
			break;

		case DT_SUNW_STRPAD:
			dyn_elt_save(&strpad_elt, ndx, &dyn);
			msg_debug("[%d]%s[%d]: DT_STRPAD: %d\n",
			    dynsec->c_ndx, dynsec->c_name, ndx,
			    (int)strpad_elt.dyn.d_un.d_val);
			break;

		case DT_FLAGS_1:
			dyn_elt_save(&flags_1_elt, ndx, &dyn);
			break;
		}
	}

	/*
	 * If this is a readonly session, then print the existing
	 * runpath and exit. DT_RPATH and DT_RUNPATH should have
	 * the same value, so we arbitrarily favor DT_RUNPATH.
	 */
	if (readonly) {
		if (runpath_elt.seen)
			(void) printf("%s\n",
			    DYN_ELT_STRING(&runpath_elt, strsec));
		else if (rpath_elt.seen)
			(void) printf("%s\n",
			    DYN_ELT_STRING(&rpath_elt, strsec));
		else
			msg_debug("ELF file does not have a runpath: %s\n",
			    file);
		return (0);
	}


	/* Edit the file, either to remove the runpath or to add/modify it */
	if (r_flg) {
		if (!(runpath_elt.seen || rpath_elt.seen))
			msg_debug("[%d]%s: no runpath found\n",
			    dynsec->c_ndx, dynsec->c_name);
		else
			changed = remove_runpath(dynsec, numdyn);
	} else {
		changed = new_runpath(runpath, dynsec, numdyn, strsec,
		    &rpath_elt, &runpath_elt, &strpad_elt, &null_elt);
	}

	if (changed) {
		/*
		 * If possible, set the DF_1_EDITED flag, indicating that
		 * this file has been edited after the fact.
		 */
		if (flags_1_elt.seen) {
			flags_1_elt.dyn.d_un.d_val |= DF_1_EDITED;
		} else if (null_elt.seen && (null_elt.ndx < (numdyn - 1))) {
			msg_debug("[%d]%s: No existing flags_1 entry to "
			    "modify. Will use extra DT_NULL in slot [%d] \n",
			    dynsec->c_ndx, dynsec->c_name, null_elt.ndx);
			flags_1_elt.seen = 1;
			flags_1_elt.ndx = null_elt.ndx;
			flags_1_elt.dyn.d_tag = DT_FLAGS_1;
			flags_1_elt.dyn.d_un.d_val = DF_1_EDITED;
		}
		if (flags_1_elt.seen) {
			msg_debug("[%d]%s[%d]: Set DF_1_EDITED flag\n",
			    dynsec->c_ndx, dynsec->c_name, flags_1_elt.ndx);
			if (gelf_update_dyn(dynsec->c_data, flags_1_elt.ndx,
			    &flags_1_elt.dyn) == 0)
				msg_elf("gelf_update_dyn");
		}

		/*
		 * Mark the data area as dirty so libelf will flush our
		 * changes to the dynamic section data.
		 */
		(void) elf_flagdata(dynsec->c_data, ELF_C_SET, ELF_F_DIRTY);

		/* Flush the file to disk */
		if (elf_update(elf, ELF_C_WRITE) == -1)
			msg_elf("elf_update");
		(void) close(fd);
		(void) elf_end(elf);
	}
	return (0);
}
