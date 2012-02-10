#!/usr/perl5/bin/perl
#
# 2010-2011, Copyright (c) Igor Kozhukhov.  All rights reserved.
# Use is subject to license terms.
#
# Igor Kozhukhov <ikozhukhov@gmail.com>
# VERSION 1.6
#

use FindBin;
use lib "$FindBin::Bin/";

use File::Path;
use File::Copy;
#use File::Find;
use File::Basename;
use Getopt::Long;
use Env;

use strict;

use MFT;

#-----------------------------------------------------------------------------#
my $noArchPkgs = {};
#$$noArchPkgs{'compress-xz'} = 1;
#$$noArchPkgs{'developer-build-cbe'} = 1;
#$$noArchPkgs{'entire'} = 1;
#$$noArchPkgs{'library-python-2-cherrypy'} = 1;
#$$noArchPkgs{'library-python-2-mako'} = 1;
#$$noArchPkgs{'library-python-2-ply'} = 1;
#$$noArchPkgs{'library-python-2-pybonjour'} = 1;
#$$noArchPkgs{'package-pkg-package-manager'} = 1;
#$$noArchPkgs{'package-pkg-update-manager'} = 1;
#$$noArchPkgs{'package-pkgbuild'} = 1;
#$$noArchPkgs{'storage-smartmontools'} = 1;
#$$noArchPkgs{'web-proxy-c-icap'} = 1;


my $ignorePkgs = {};
$$ignorePkgs{'consolidation-osnet-osnet-message-files'} = 1;
$$ignorePkgs{'consolidation-osnet-osnet-incorporation'} = 1;
$$ignorePkgs{'consolidation-osnet-osnet-redistributable'} = 1;
#$$ignorePkgs{'developer-build-onbld'} = 1;

my $specialPkgs = {};
$$specialPkgs{'system-file-system-zfs'} = 1;
$$specialPkgs{'system-file-system-zfs-tests'} = 1;
$$specialPkgs{'system-file-system-udfs'} = 1;
$$specialPkgs{'system-floating-point-scrubber'} = 1;
$$specialPkgs{'system-tnf'} = 1;
$$specialPkgs{'diagnostic-cpu-counters'} = 1;
$$specialPkgs{'driver-network-eri'} = 1;
$$specialPkgs{'compatibility-ucb'} = 1;
$$specialPkgs{'diagnostic-powertop'} = 1;
$$specialPkgs{'diagnostic-latencytop'} = 1;
$$specialPkgs{'network-ipfilter'} = 1;
$$specialPkgs{'developer-debug-mdb'} = 1;
$$specialPkgs{'system-extended-system-utilities'} = 1;
$$specialPkgs{'storage-library-network-array'} = 1;
$$specialPkgs{'service-resource-cap'} = 1;
$$specialPkgs{'developer-linker'} = 1;
$$specialPkgs{'developer-dtrace'} = 1;
$$specialPkgs{'driver-network-eri'} = 1;


#-----------------------------------------------------------------------------#
my $tmpl = {};
$$tmpl{'PKGVER'} = $ENV{'PKGVER'};
my $modulesList = [];
my @dirs = "";
#-----------------------------------------------------------------------------#
#------------------------------
# main
#------------------------------
{
    my @pkgName = "";
    $pkgName[0] = 'all';
    my $result = GetOptions ( "p|pkg|package=s" => \@pkgName,
				"d|dir=s" => \@dirs);
#    print "$result, $pkg\n";
#    exit 0;

    unless ($ENV{"BASEGATE"})
    {
	print "BASEGATE not defined!\n";
	exit (1);
    }
    else
    {
	my $gatePath = "$ENV{'BASEGATE'}";
    }

    unless ($ENV{'MANIFESTGATE'})
    {
        $ENV{'MANIFESTGATE'} = $ENV{'BASEGATE'}.'/usr/src/pkg/manifests';
    }

    unless ($ENV{'DESTINATION'})
    {
	$$tmpl{'DESTANATION'} = "$FindBin::Bin/packages";
    }
    else
    {
	$$tmpl{'DESTANATION'} = "$ENV{'DESTINATION'}";
    }

    unless ($ENV{'MAINTAINER'})
    {
	$$tmpl{'MAINTAINER'} = 'Igor Kozhukhov <ikozhukhov@gmail.com>';
    }
    else
    {
	$$tmpl{'MAINTAINER'} = "$ENV{'MAINTAINER'}";
    }

    unless ($ENV{'MFEXT'})
    {
	$$tmpl{'MFEXT'} = 'mog';
    }
    else
    {
	$$tmpl{'MFEXT'} = "$ENV{'MFEXT'}";
    }

    unless ($ENV{'PKGTYPE'})
    {
	$$tmpl{'CATEGORY'} = 'undef';
    }
    else
    {
	$$tmpl{'CATEGORY'} = "$ENV{'PKGTYPE'}";
    }

    my $templates = &initTemplates();

#    find( \&d, $ENV{'MANIFESTGATE'});
#    find( { wanted => \&d }, $ENV{'MANIFESTGATE'});

    if ($pkgName[0] eq 'all' && scalar(@pkgName) < 2)
    {
	&modulesList($ENV{'MANIFESTGATE'});
    }
    else
    {
	my $str = "\.".$$tmpl{'MFEXT'}."\$";
	foreach my $pkgNameOne (@pkgName)
	{
	    $pkgNameOne = basename ($pkgNameOne);
	    $pkgNameOne =~ s/$str//;
#	    print "$pkgNameOne\n";
	    push(@$modulesList, $pkgNameOne) unless ($pkgNameOne =~ /\.\// || $pkgNameOne eq 'all');
	}
    }

#print "== @pkgName\n";
#print "== @$modulesList\n";

#    my $ARCH = system("uname -p");
#    &genPackage('sunwcs');
#    &saveDepends('developer-gcc-3');
#    &saveDepends('library-gmp');
#exit 0;

    my $pkgFailed = [];
    foreach my $pkg (sort @$modulesList)
    {
        next if (defined($$ignorePkgs{$pkg}));
        next if ($pkg =~ /^consolidation-/i);
#print "== '$pkg'\n";
        print "Generating structure from file: $pkg ... ";
        my $oPackage = &genPackage($pkg);
#        my $res = ($oPackage) ? $oPackage : 'OK';
        my $res = ($oPackage) ? 'FAILED' : 'OK';
        print "- $res\n";
        print "-------------------------------------------------------------\n";
        push(@$pkgFailed, "$pkg ($oPackage)") if ($res eq 'FAILED');
    }

    if (scalar(@$pkgFailed) > 0)
    {
        open(LOG, ">", "ips2deb.failed.txt") or die "Can't open 'ips2deb.failed.txt' : $!";
        my $str = "\n";
        $str .= "1 - absent 'dir'\n";
        $str .= "2 - absent 'file'\n";
        $str .= "3 - absent 'hardlink'\n";
        $str .= "4 - absent 'driver'\n";
        $str .= "5 - absent 'link'\n";
        $str .= "6 - absent 'user'\n";
        $str .= "7 - absent 'group'\n";
        $str .= "8 - arch != i386\n";
        $str .= "9 - PkgObsolete\n";
        $str .= "0 - PkgRenamed\n";
        $str .= "a - absent depends\n";
        $str .= "b - ignored packages\n";
        print LOG "Help: \n$str\n\n";
        print LOG "Failed packages:".scalar(@$pkgFailed)."\n\t".join("\n\t", @$pkgFailed);
        close(LOG);
    }

}

sub d
{
    my $str = "\.".$$tmpl{'MFEXT'}."\$";
#    /\.mf$/ or return;
    /$str/ or return;

    my $mod = basename($File::Find::name);
#    $mod =~ s/\..*$//;
    $mod =~ s/$str//;
    if ($mod =~ /^SUNW/i)
    {
        return unless ($mod =~ /^SUNWcsd$/i || $mod =~ /^SUNWcs$/i);
    }
#    print "$str, $mod\n";
    push(@$modulesList, $mod);
}

sub modulesList ()
{
    my $dir = shift;

    my $str = "\.".$$tmpl{'MFEXT'}."\$";

    my @files = <$dir/*>;
    foreach my $line (@files)
    {
	next unless ($line =~ /$str/);
	my $mod = basename($line);
	$mod =~ s/$str//;
	if ($mod =~ /^SUNW/i)
	{
	    next unless ($mod =~ /^SUNWcsd$/i || $mod =~ /^SUNWcs$/i);
	}
	push(@$modulesList, $mod) unless defined($$ignorePkgs{$mod});
    }
}


#------------------------------
# genPackage
#------------------------------
sub genPackage
{
    my ($package) = @_;

    my $packageFile;
    $packageFile = $package.".".$$tmpl{'MFEXT'};
    $packageFile =~ /^SUNWcs\./ if ($package eq 'sunwcs');
    $packageFile = /^SUNWcsd\./ if ($package eq 'sunwcsd');
    $packageFile = $ENV{'MANIFESTGATE'}."/".$packageFile;

    $$tmpl{'DEPENDENCES'} = '${shlibs:Depends}, ${misc:Depends}';
    $$tmpl{'FIXPERMS'} = '';
    $$tmpl{'POSTINST_CONFIGURE'} = '';
    $$tmpl{'PREINST_INSTALL'} = '';
    $$tmpl{'PRERM_UPGRADE'} = '';
    $$tmpl{'CONFFILES'} = '';
    $$tmpl{'ZONE'} = '';
    $$tmpl{'ORIGINALVERSION'} = '';
    $$tmpl{'ORIGINALNAME'} = '';
    $$tmpl{'REPLACES'} = '';
#    $$tmpl{'REPLACES'} = "\nReplases: xxx";

    my %replaces;
    open(REP, "$FindBin::Bin/ips2deb.replaces") or die "Error open file '$FindBin::Bin/ips2deb.replaces' : $!\n";
    while(<REP>)
    {
	chomp;
	next if /^(\s)*$/;  # skip blank lines
	next if /^#/;       # skip comments lines
	next if /^\s*#/;    # skip comments lines
	my @lines = split(/:/);
	$replaces{$lines[0]} = $lines[1];
    }
    close(REP);

    my $mft = new MFT();
    my $str = '';
    my $file = '';
    my $dep = [];

    $mft->init();
#print "== pkgFile = $packageFile\n";
    $mft->readMfFile($packageFile);
#print "== 2\n";
    $$tmpl{'PKGNAME'} = $mft->getModuleName();
    $$tmpl{'PKGSHORTDESCRIPTION'} = $mft->getShortDescription();
    $$tmpl{'PKGDESCRIPTION'} = $mft->getDescription();
    $$tmpl{'ORIGINALVERSION'} = $mft->getOrigVersion();
    $$tmpl{'ORIGINALNAME'} = $mft->getOrigName();
    $$tmpl{'SAVETO'} = $$tmpl{'DESTANATION'}.'/'.$$tmpl{'PKGNAME'}.'/debian';

#    return '8' unless (defined($$noArchPkgs{$$tmpl{'PKGNAME'}})) || $mft->getArch() eq 'i386';
    return '8' unless ($mft->getArch() eq 'i386');
    return '9' if ($mft->getPkgObsolete() eq 'true');
    return '0' if ($mft->getPkgRenamed() eq 'true');
    return 'b' if (defined($$ignorePkgs{$$tmpl{'PKGNAME'}}));
    return 'b' if ($$tmpl{'PKGNAME'} =~ /^consolidation-/i);

    $str = "test -d $$tmpl{'DESTANATION'}/$$tmpl{'PKGNAME'} && rm -rf $$tmpl{'DESTANATION'}/$$tmpl{'PKGNAME'}";
#print "== $str == ";
    system($str);

    my $res='';
    my $oDirs = &saveDirs($mft);
    $res = '1' if ($oDirs);
    my $oFiles = &saveFiles($mft);
    $res .= '2' if ($oFiles);
    my $oHardLinks = &saveHardLinks($mft);
    $res .= '3' if ($oHardLinks);
    my $oDrivers = &saveDrivers($mft);
    $res .= '4' if ($oDrivers);
    my $oLinks = &saveLinks($mft);
    $res .= '5' if ($oLinks);
    my $oGroups = &saveGroups($mft);
    $res .= '7' if ($oGroups);
    my $oUsers = &saveUsers($mft);
    $res .= '6' if ($oUsers);
    $dep = $mft->getDepend();
    $res .= 'a' unless (defined($dep) && scalar($dep) > 0);

    return $res if ($oDirs && $oFiles && $oHardLinks && $oUsers && $oGroups && ($res =~ /^a/));

# fill scripts and conffiles
    my $templates = &initTemplates();
    my $output = $mft->getScripts();

# postinst
    my $operation = 'postinst';
    my $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'POSTINST_CONFIGURE'} = join("\n\t",@$operations);
        &saveExtfiles($mft, $operation);
    }

# preinst
    $operation = 'preinst';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'PREINST_INSTALL'} = join("\n\t",@$operations);
        &saveExtfiles($mft, $operation);
    }

# prerm
    $operation = 'prerm';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'PRERM_UPGRADE'} = join("\n\t",@$operations);
        &saveExtfiles($mft, $operation);
    }

    $operation = 'fixperms';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'PATH'} = '/usr/bin:/sbin:/usr/sbin';
        $$tmpl{'FIXPERMS'} = join("\n",@$operations);
        &saveExtfiles($mft, $operation);
    }
    else
    {
        my $str = fillTemplate($$templates{$operation});
        my $file = $$tmpl{'SAVETO'}.'/'.$$tmpl{'PKGNAME'}.'.'.$operation;
        &saveFinalFile($file, $str);
    }

    $operation = 'conffiles';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'CONFFILES'} = join("\n",@$operations);
        &saveExtfiles($mft, $operation);
    }

#    $operation = 'zone';
#    undef $operations;
#    $operations = $$output{$operation} if defined($$output{$operation});
#    if (defined ($operations) && scalar(@$operations) > 0)
#    {
#        $$tmpl{'ZONE'} = @$operations[0];
#    }

    $operation = 'changelog';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);


    $$tmpl{'DEPENDENCES'} .= ', sunwcs' if ($$specialPkgs{$$tmpl{'PKGNAME'}});
#    $dep = $mft->getDepend();
#    print "== @$dep\n";
    $$tmpl{'DEPENDENCES'} .= ', '.join(', ', @$dep) if (defined($dep) && scalar(@$dep) > 0);

    $$tmpl{'REPLACES'} = "\nReplaces: ".$replaces{$$tmpl{'PKGNAME'}} if (defined($replaces{$$tmpl{'PKGNAME'}}));

    $operation = 'control';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);

    $operation = 'copyright';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);

    $operation = 'compat';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);

    $operation = 'rules';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);
    $str = "chmod 0755 $file";
    system($str);

    return 0;
}

#-----------------------------------------------------------------------------#

#------------------------------
# fillTemplate
#------------------------------
sub fillTemplate
{
#    my ( $file ) = @_;
    my ( $template ) = @_;
    
    my $str = '';

    $str = $template;

    my $curDate = qx(date "+%a, %d %h %Y %H:%M:%S %z");
    chomp($curDate);
    $$tmpl{'DATE'} = $curDate;

    $str =~ s/%%PKGNAME%%/$$tmpl{'PKGNAME'}/g;
    $str =~ s/%%PKGVER%%/$$tmpl{'PKGVER'}/g;
    $str =~ s/%%MAINTAINER%%/$$tmpl{'MAINTAINER'}/g;
    $str =~ s/%%PKGSHORTDESCRIPTION%%/$$tmpl{'PKGSHORTDESCRIPTION'}/g;
    $str =~ s/%%PKGDESCRIPTION%%/$$tmpl{'PKGDESCRIPTION'}/g;
    $str =~ s/%%DEPENDENCES%%/$$tmpl{'DEPENDENCES'}/g;
    $str =~ s/%%DATE%%/$$tmpl{'DATE'}/g;
    $str =~ s/%%FIXPERMS%%/$$tmpl{'FIXPERMS'}/g;
    $str =~ s/%%PATH%%/$$tmpl{'PATH'}/g;
    $str =~ s/%%POSTINST_CONFIGURE%%/$$tmpl{'POSTINST_CONFIGURE'}/g;
    $str =~ s/%%PREINST_INSTALL%%/$$tmpl{'PREINST_INSTALL'}/g;
    $str =~ s/%%PRERM_UPGRADE%%/$$tmpl{'PRERM_UPGRADE'}/g;
    $str =~ s/%%CONFFILES%%/$$tmpl{'CONFFILES'}/g;
#    $str =~ s/%%SHLIBS%%/$$tmpl{'SHLIBS'}/g;
#    $str =~ s/%%ZONE%%/$$tmpl{'ZONE'}/g;
    $str =~ s/%%ORIGINALVERSION%%/$$tmpl{'ORIGINALVERSION'}/g;
    $str =~ s/%%ORIGINALNAME%%/$$tmpl{'ORIGINALNAME'}/g;
    $str =~ s/%%CATEGORY%%/$$tmpl{'CATEGORY'}/g;
    $str =~ s/%%REPLACES%%/$$tmpl{'REPLACES'}/g;

    return $str;
}

#------------------------------
# saveFinalFile
#------------------------------
sub saveFinalFile
{
    my ( $file, $str ) = @_;

    my $dirName = dirname($file);
    system("mkdir -p $dirName");

    local *FILE;
    open (FILE, ">", $file);
    print FILE "$str\n";
    close (FILE);
}

#------------------------------
# saveExternalfiles
#------------------------------
sub saveExtfiles
{
    my ($mft, $operation) = @_;

    my $output = $mft->getScripts();
    my $templates = &initTemplates();
#    my $moduleName = $mft->getModuleName();
    my $operations = $$output{$operation} if defined($$output{$operation});
#    print join("\n", @$operations) if defined($$output{$operation});
    return unless defined($$output{$operation});

#    my $str = fillTemplate('tmpl/'.$operation.'.tmpl');
    my $str = fillTemplate($$templates{$operation});
    my $file = $$tmpl{'SAVETO'}.'/'.$$tmpl{'PKGNAME'}.'.'.$operation;
    &saveFinalFile($file, $str);
}

#------------------------------
# saveDepends()
#------------------------------
sub saveDepends
{
#    my ($mft) = @_;
    my ($package) = @_;
    my $packageFile = "manifests/".$package.".mf";

    my $mft = new MFT();
    $mft->init();
    $mft->readMfFile($packageFile);
    my $res = [];
    $res = $mft->getDepend();

    print join(', ', @$res)."\n";
}

#------------------------------
# saveFiles()
#------------------------------
sub saveFiles
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'file'});

    my $r = $$mf{'file'};
    my $moduleName = $mft->getModuleName();

    my $str;
    my $found = 0;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];
    my $preinst = [];
    my $postrm = [];
    my $prerm = [];
    my $conffiles = [];
    my $fixperms = [];
    my $zone = [];
    my $svcChk = {};

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $preinst = $$output{'preinst'} if (defined($$output{'preinst'}));
    $postrm = $$output{'postrm'} if (defined($$output{'postrm'}));
    $prerm = $$output{'prerm'} if (defined($$output{'prerm'}));
    $conffiles = $$output{'conffiles'} if (defined($$output{'conffiles'}));
    $fixperms = $$output{'fixperms'} if (defined($$output{'fixperms'}));
    $zone = $$output{'zone'} if (defined($$output{'zone'}));

    if ($moduleName eq 'sunwcs')
    {
	$str = "cp -f \$BASEDIR/usr/bin/cp \$BASEDIR/usr/bin/ln";
	push (@$postinst, $str);

#	$str = "mkdir -p cp -f \$BASEDIR/usr/bin/cp \$BASEDIR/usr/bin/ln";
#        push(@$fixperms, "mkdir -p \$DEST/$path_dir");

	$str = "cp -f \$BASEDIR/usr/lib/isaexec \$BASEDIR/usr/bin/ksh";
	push (@$postinst, $str);

	$str = "cp -f \$BASEDIR/usr/lib/isaexec \$BASEDIR/usr/bin/ksh93";
	push (@$postinst, $str);
    }

    my @buff;
    my @buffperm;
    my $file = $$tmpl{'SAVETO'}.'/'.$moduleName.".install";
    my $fileperm = $$tmpl{'SAVETO'}.'/'.$moduleName.".files.fixperm";

    foreach my $line (@$r)
    {
        my $preserve = $$line{'preserve'}[0] if defined($$line{'preserve'});
        my $restart_fmri = $$line{'restart_fmri'}[0] if defined($$line{'restart_fmri'});
        my $arch = $$line{'variant.arch'}[0] if defined($$line{'variant.arch'});

        my $zonevariant = $$line{'variant.opensolaris.zone'}[0] if defined($$line{'variant.opensolaris.zone'});

#        my $group = defined($$line{'group'}) ? $$line{'group'}[0] : 'root';
#        my $mode = defined($$line{'mode'}) ? $$line{'mode'}[0] : '0644';
#        my $owner = defined($$line{'owner'}) ? $$line{'owner'}[0] : 'root';
        my $group = $$line{'group'}[0];
        my $mode = $$line{'mode'}[0];
        my $owner = $$line{'owner'}[0];

#        my $chash = $$line{'chash'}[0] if defined($$line{'chash'});
        my $path = $$line{'path'}[0]; # if defined($$line{'path'});
        my $path_dir = dirname($path);
        my $path_others = $$line{'others'}[0]; # if defined($$line{'others'});
        my $origPath = $path;

        next if ($path =~ /etc\/motd/); # use etc/motd from base-files package

        # workaround - NEED fix later for SPARC
#        next if (defined($$line{'variant.arch'}) && ($arch ne 'i386'));

#        $mode = '0755' if ($path =~ /.*\.so.*/); # fix shared libs attribute

        if (defined($$line{'preserve'}) && $preserve eq 'true')
        {
#            push(@$conffiles, "$path") unless ($path =~ /etc\//);
#            push(@$conffiles, "$path");
            push(@$conffiles, "$origPath");
        }

        if (defined($zonevariant) && ($zonevariant eq 'global'))
        {
	    $str = "[ \"\$ZONEINST\" = \"1\" ] && ([ -f \$BASEDIR/$path ] && rm -f \$BASEDIR/$path)";
            push(@$postinst, $str);
        }

        if (defined($restart_fmri))
        {
            unless(defined($$svcChk{"$restart_fmri"}))
            {
                $$svcChk{"$restart_fmri"} = 1;
#                push(@$postinst, "if [ \"\$BASEDIR\" = \"/\" ]; then");
                push(@$postinst, "\$BASEDIR/usr/sbin/svcadm restart $restart_fmri || true");
#                push(@$postinst, "fi");
            }
        }

        push(@$fixperms, "mkdir -p \$DEST/$path_dir");

#	$str = "mkdir -p $$tmpl{'SAVETO'}/tmp";
#	system($str);

	$found = 0;
	undef($path_others) if ($path_others =~ /NOHASH/ || defined($$line{'chash'}));
        if (defined($path_others))
        {
	    $str = dirname("$origPath");
	    mkpath("$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$str");

	    foreach my $dirOne (@dirs)
	    {
		next unless (-e "$dirOne/$path_others" && -f "$dirOne/$path_others");
		copy("$dirOne/$path_others", "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath") or die "Copy failed:($dirOne/$path_others), $!";
		chown $owner, $group, "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath";
		chmod oct("$mode"), "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath";
#		last if ($? == 0);
	    $found = 1;
	    }

#	    push(@$fixperms, "test -f debian/_special_/$path_others && cp -f debian/_special_/$path_others \$DEST/$path");
        }
        else
        {
	    foreach my $dirOne (@dirs)
	    {
		next if (length($dirOne) < 3);
#		print "1 - == $dirOne, $path, $origPath\n";
		next unless (-e "$dirOne/$origPath" && -f "$dirOne/$origPath");
#		print "2 - == $dirOne/$path\n";
		$str = dirname("$origPath");
		mkpath("$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$str");
		copy("$dirOne/$origPath", "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath") or die "Copy failed: $!";
		chown $owner, $group, "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath";
		chmod oct("$mode"), "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath";
#		push(@$fixperms, "mv \"$$tmpl{'SAVETO'}/proto/$path\" \"\$DEST/$str/\"");
#		push(@$fixperms, "mv $$tmpl{'SAVETO'}/proto/$path \$DEST/$path");
		$found = 1;
		last;
	    }
        }
        unless ($found)
        {
	    print "FAILED!\n==NOT found: $path\n"; 
	    exit 1;
        }

#        push(@buff, "$path");

        push(@$fixperms, "test -f \"\$DEST/$origPath\" || echo '== Missing: $origPath'");
        push(@$fixperms, "test -f \"\$DEST/$origPath\" || exit 1");
        push(@$fixperms, "chmod $mode \"\$DEST/$origPath\"");
        push(@$fixperms, "chown $owner:$group \"\$DEST/$origPath\"");
    }
#    return 1 if (scalar(@buff) < 1);
#    return 1 if (scalar(@$fixperms) < 1);
    return 1 unless ($found);
#    &saveFinalFile($file, join("\n", @buff));

#    $str = "";
#    push (@$postinst, $str) if (scalar(@$postinst) > 0);


#    if ($moduleName eq 'system-library')
#    {
#        push (@$preinst, "mount | grep -c /lib/libc.so.1 >/dev/null && umount /lib/libc.so.1");
#    }


    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'preinst'} = $preinst if (scalar(@$preinst) > 0);
    $$output{'postrm'} = $postrm if (scalar(@$postrm) > 0);
    $$output{'prerm'} = $prerm if (scalar(@$prerm) > 0);
    $$output{'conffiles'} = $conffiles if (scalar(@$conffiles) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);
    $$output{'zone'} = $zone if (scalar(@$zone) > 0);

    $mft->{_scripts} = $output;
    return 0;
}


#------------------------------
# saveDirs()
#------------------------------
sub saveDirs
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'dir'});

    my $r = $$mf{'dir'};
    my $moduleName = $mft->getModuleName();

    my $str;
    my $found = 0;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];
    my $fixperms = [];
    
    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $fixperms = $$output{'fixperms'} if (defined($$output{'fixperms'}));

    my @buff;
#    my @buffperm;
    my $file = $$tmpl{'SAVETO'}.'/'.$moduleName.".dirs";
#    my $fileperm = $$tmpl{'SAVETO'}.'/'.$moduleName.".dirs.fixperm";
    foreach my $line (@$r)
    {
        my $arch = $$line{'variant.arch'}[0] if defined($$line{'variant.arch'});

#        my $group = defined($$line{'group'}) ? $$line{'group'}[0] : 'root';
#        my $mode = defined($$line{'mode'}) ? $$line{'mode'}[0] : '0755';
#        my $owner = defined($$line{'owner'}) ? $$line{'owner'}[0] : 'root';
        my $group = $$line{'group'}[0];
        my $mode = $$line{'mode'}[0];
        my $owner = $$line{'owner'}[0];

        my $path = $$line{'path'}[0];
#        my $zonevariant = $$line{'variant.opensolaris.zone'}[0] if defined($$line{'variant.opensolaris.zone'});

        # workaround - NEED fix later for SPARC
#        next if (defined($$line{'variant.arch'}) && ($arch ne 'i386'));

#        push(@buff, "$path");
#        push(@$fixperms, "mkdir -p \$DEST/$path");

#        if (defined($zonevariant) && ($zonevariant eq 'global'))
#        {
#	    $str = "[ \"\$ZONEINST\" = \"1\" ] && ([ -d \$BASEDIR/$path ] && rm -rf \$BASEDIR/$path)";
#            push(@$postinst, $str);
#        }

	mkpath("$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$path", 
		{mode => oct($mode), uwner => $owner, group => $group});
#	chown $owner, $group, "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$path";
#	chmod $mode, "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$path";

#        push(@buffperm, "chmod $mode \$DEST/$path");
#        push(@buffperm, "chown $owner:$group \$DEST/$path");

        push(@$fixperms, "chmod $mode \$DEST/$path");
        push(@$fixperms, "chown $owner:$group \$DEST/$path");
        $found = 1;
    }
##    return 1 if (scalar(@buff) < 1);
#    return 1 if (scalar(@$fixperms) < 1);
    return 1 unless ($found);
##    &saveFinalFile($file, join("\n", @buff));
#    &saveFinalFile($fileperm, join("\n", @buffperm));

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);
    $mft->{_scripts} = $output;
    return 0;
}

#------------------------------
# saveUsers
#------------------------------
sub saveUsers
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'user'});

    my $r = $$mf{'user'};
    my $moduleName = $mft->getModuleName();
    my $str;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));

    foreach my $user (@$r)
    {
        $str = '';
        push (@$postinst, $str);
        $str = "if ! getent passwd $$user{'username'}[0] >/dev/null 2>\&1 ; then";
        push (@$postinst, $str);
#        $str = "adduser --system --no-create-home ";
#        $str .= "--gecos $$user{'gcos-field'}[0] " if defined ($$user{'gcos-field'});
#        $str .= "--home $$user{'home-dir'}[0] " if defined ($$user{'home-dir'});
#        $str .= "--shell $$user{'login-shell'}[0] " if defined ($$user{'login-shell'});
#        $str .= "--uid $$user{'uid'}[0] ";
#        $str .= "--ingroup $$user{'group'}[0] " if defined ($$user{'group'});
#        $str .= " $$user{'username'}[0]";
        $str = "useradd ";
        $str .= " -c $$user{'gcos-field'}[0] " if defined ($$user{'gcos-field'});
#        $str .= " -d $$user{'home-dir'}[0] " if defined ($$user{'home-dir'});
        $str .= " -s $$user{'login-shell'}[0] " if defined ($$user{'login-shell'});
        $str .= " -u $$user{'uid'}[0] ";
        $str .= " -g $$user{'group'}[0] " if defined ($$user{'group'});
        $str .= " -m $$user{'username'}[0]";
        push (@$postinst, $str);
        $str = "fi";
        push (@$postinst, $str);
    }

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);

    $mft->{_scripts} = $output;
    return 0;
}


#------------------------------
# saveGroups
#------------------------------
sub saveGroups
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'group'});

    my $r = $$mf{'group'};
    my $moduleName = $mft->getModuleName();
    my $str;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));

    foreach my $grp (@$r)
    {
        $str = '';
        push (@$postinst, $str);
        $str = "if ! getent group $$grp{'groupname'}[0] >/dev/null 2>\&1 ; then";
        push (@$postinst, $str);
        $str = "groupadd -g $$grp{'gid'}[0] $$grp{'groupname'}[0]";
        push (@$postinst, $str);
        $str = "fi";
        push (@$postinst, $str);
    }

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);

    $mft->{_scripts} = $output;
    return 0;
}

#------------------------------
# saveLinks
#------------------------------
sub saveLinks
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'link'});

    my $r = $$mf{'link'};
    my $moduleName = $mft->getModuleName();
    my $str;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];
    my $fixperms = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $fixperms = $$output{'fixperms'} if (defined($$output{'fixperms'}));

#    my $file = $$tmpl{'SAVETO'}.'/'.$mft->getModuleName().".links";
    my @buff;
    foreach my $line (@$r)
    {
        my $path = $$line{'path'}[0];
        my $target = $$line{'target'}[0];

        my $zonevariant;
        $zonevariant = $$line{'variant.opensolaris.zone'}[0] if defined($$line{'variant.opensolaris.zone'});
#        push(@buff, "$target $path");

        my $dir;
        $dir = dirname("$path");
        if (defined($zonevariant) && ($zonevariant eq 'global'))
        {
	    $str = "[ \"\$ZONEINST\" = \"1\" ] || (mkdir -p \$BASEDIR/$dir && ln -f -s $target \$BASEDIR/$path)";
            push(@$postinst, $str);
        }
        else
        {
	    $str = "mkdir -p \$DEST/$dir && ln -f -s $target \$DEST/$path";
	    push (@$fixperms, $str);
        }

    }
#    &saveFinalFile($file, join("\n", @buff));

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);

    $mft->{_scripts} = $output;
    return 0;
}


#------------------------------
# saveHardLinks
#------------------------------
sub saveHardLinks
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'hardlink'});

    my $r = $$mf{'hardlink'};
    my $moduleName = $mft->getModuleName();
    my $str;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];
    my $preinst = [];
    my $postrm = [];
    my $prerm = [];
    my $fixperms = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $preinst = $$output{'preinst'} if (defined($$output{'preinst'}));
    $postrm = $$output{'postrm'} if (defined($$output{'postrm'}));
    $prerm = $$output{'prerm'} if (defined($$output{'prerm'}));
    $fixperms = $$output{'fixperms'} if (defined($$output{'fixperms'}));

    if ($moduleName eq 'sunwcs')
    {
	$str = "mkdir -p \$DEST/usr/bin && cp -f \$DEST/usr/bin/cp \$DEST/usr/bin/ln";
        push(@$fixperms, $str);

	$str = "mkdir -p \$DEST/usr/bin && cp -f \$DEST/usr/lib/isaexec \$DEST/usr/bin/ksh";
        push(@$fixperms, $str);

	$str = "mkdir -p \$DEST/usr/bin && cp -f \$DEST/usr/lib/isaexec \$DEST/usr/bin/ksh93";
        push(@$fixperms, $str);
    }


    foreach my $line (@$r)
    {
        my $path = $$line{'path'}[0];
        my $target = $$line{'target'}[0];
        my $destDir = dirname($path);
        my $destFile = basename($path);
        my $zonevariant = $$line{'variant.opensolaris.zone'}[0] if defined($$line{'variant.opensolaris.zone'});

	next if ($path eq "usr/bin/ln");
	next if ($path eq "usr/bin/ksh");
	next if ($path eq "usr/bin/ksh93");

        if (defined($zonevariant) && ($zonevariant eq 'global'))
        {

            $str = "[ \"\$ZONEINST\" = \"1\" ] || (mkdir -p \$BASEDIR/$destDir && cd \$BASEDIR/$destDir && ln -f $target $destFile)";
            push (@$postinst, $str);

            $str = "[ \"\$ZONEINST\" = \"1\" ] || rm -f \$BASEDIR/$path";
            push (@$prerm, $str);
        }
        else
        {
            $str = "mkdir -p \$BASEDIR/$destDir && (cd \$BASEDIR/$destDir && ln -f $target $destFile)";
            push (@$postinst, $str);

            $str = "rm -f \$BASEDIR/$path";
            push (@$prerm, $str);
        }
    }

#    $str = "";
#    push (@$postinst, $str) if (scalar(@$postinst) > 0);

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'preinst'} = $preinst if (scalar(@$preinst) > 0);
    $$output{'postrm'} = $postrm if (scalar(@$postrm) > 0);
    $$output{'prerm'} = $prerm if (scalar(@$prerm) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);

    $mft->{_scripts} = $output;
    return 0;
}

#------------------------------
# saveDrivers
#------------------------------
sub saveDrivers
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'driver'});
    my $r = $$mf{'driver'};

    my $str;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];
    my $preinst = [];
    my $postrm = [];
    my $prerm = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $preinst = $$output{'preinst'} if (defined($$output{'preinst'}));
    $postrm = $$output{'postrm'} if (defined($$output{'postrm'}));
    $prerm = $$output{'prerm'} if (defined($$output{'prerm'}));

#    local *FILE;
#    open (FILE, ">", $mft->getModuleName().".drivers");
    foreach my $line (@$r)
    {
        my $name = $$line{'name'}[0] if defined($$line{'name'});
        my $privs = $$line{'privs'}[0] if defined($$line{'privs'});
        my $policy = $$line{'policy'}[0] if defined($$line{'policy'});
        my $devlink = $$line{'devlink'}[0] if defined($$line{'devlink'});

        my $originalPerm;
        my $originalClonePerm;

        my $drv = 'add_drv -n ';

        $originalPerm = $$line{'perms'} if defined($$line{'perms'});
        $originalClonePerm = $$line{'clone_perms'} if defined($$line{'clone_perms'});

        my $perms = '';
        my $OPTIONS = '';

        $OPTIONS .= " -P $privs" if defined($privs);

        my $classes = $$line{'class'} if defined($$line{'class'});
        my $class = '';
        if (defined($classes))
        {
            if (scalar($classes) > 1)
            {
                $class .= join(" ", @$classes);
            }
            else
            {
                $class = @$$classes[0];
            }
            $OPTIONS .= " -c '$class'";
        }

        my $aliases = $$line{'alias'} if defined($$line{'alias'});
        my $alias = '';
        if (defined($aliases))
        {
            if (scalar($aliases) > 1)
            {
                $alias .= join("\" \"", @$aliases);
            }
            else
            {
                $alias = @$aliases[0];
            }
            $OPTIONS .= " -i '\"$alias\"'";
        }

        if (defined($originalPerm))
        {
            if ($originalPerm)
            {
                if (scalar(@$originalPerm) > 1)
                {
                    $perms = join(",", @$originalPerm);
                }
                else
                {
                    $perms = $$originalPerm[0];
                }
                $perms =~ s/"/'/g;
                $OPTIONS .= " -m $perms";
            }
        }

        $policy =~ s/"/'/g if defined($policy);
        $OPTIONS .= " -p $policy" if defined($policy);

	$str = "[ \"\$ZONEINST\" = \"1\" ] || (grep -c \"^$name \" \$BASEDIR/etc/name_to_major >/dev/null || $drv \$BASEDIR_OPT $OPTIONS $name)";
        push (@$postinst, $str);

        $str = "rem_drv \$BASEDIR_OPT $name";
        push (@$prerm, $str);

        if (defined($originalClonePerm))
        {
            $drv = 'update_drv -a -n ';

            $perms = '';
            $OPTIONS = '';
            $OPTIONS .= " -P $privs" if defined($$line{'privs'});
            $OPTIONS .= " -i '$alias'" if (defined($$line{'alias'}) && ! defined($$line{'perms'}));
            $OPTIONS .= " -c '$class'" if (defined($$line{'class'}) && ! defined($$line{'perms'}));;

            if ($originalClonePerm)
            {
                $policy =~ s/"/'/g if defined($policy);
                $OPTIONS .= " -p $policy" if defined($policy);

                foreach $perms (@$originalClonePerm)
                {
                    $perms =~ s/"/'/g;

                    $str = "[ \"\$ZONEINST\" = \"1\" ] || (grep -c \"$perms\" \$BASEDIR/etc/minor_perm >/dev/null || $drv \$BASEDIR_OPT $OPTIONS -m $perms clone)";
                    push (@$postinst, $str);
                }
            }
        }

        if(defined($devlink))
        {
            $devlink =~ s/\\t/\t/g;
            $str = "[ \"\$ZONEINST\" = \"1\" ] || (grep -c \"$devlink\" \$BASEDIR/etc/devlink.tab >/dev/null || echo \"$devlink\" >> \$BASEDIR/etc/devlink.tab)";
            push (@$postinst, $str);
        }
    }
#    close (FILE);

    $str = "";
    push (@$postinst, $str) if (scalar(@$postinst) > 0);
    push (@$prerm, $str) if (scalar(@$prerm) > 0);

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'preinst'} = $preinst if (scalar(@$preinst) > 0);
    $$output{'postrm'} = $postrm if (scalar(@$postrm) > 0);
    $$output{'prerm'} = $prerm if (scalar(@$prerm) > 0);

    $mft->{_scripts} = $output;
    return 0;
}

#------------------------------
# initTemplates()
#------------------------------
sub initTemplates
{
    my $initTemplate = {};

# changelog
$$initTemplate{'changelog'} = '%%PKGNAME%% (%%PKGVER%%) unstable; urgency=low

  * Temporary file, need only for package generation process

 -- %%MAINTAINER%%  %%DATE%%
';

# compat
$$initTemplate{'compat'} = '7';

# conffiles
$$initTemplate{'conffiles'} = '%%CONFFILES%%';

# control
$$initTemplate{'control'} = 'Source: %%PKGNAME%%
Section: %%CATEGORY%%
Priority: optional
XBS-Original-Version: %%ORIGINALVERSION%%
XBS-Category: %%CATEGORY%%
Maintainer: %%MAINTAINER%%

Package: %%PKGNAME%%
Architecture: solaris-i386
Depends: %%DEPENDENCES%%
Provides: %%ORIGINALNAME%%%%REPLACES%%
Description: %%PKGSHORTDESCRIPTION%%
 %%PKGDESCRIPTION%%
';

# copyright
$$initTemplate{'copyright'} = '
Copyright:

Copyright (c) 2011 illumian.  All rights reserved.
Use is subject to license terms.
';

# fixperms
$$initTemplate{'fixperms'} = '#!/bin/sh

export PATH=%%PATH%%

%%FIXPERMS%%
';

# postinst
$$initTemplate{'postinst'} = '#!/bin/sh

# postinst script for %%PKGNAME%%
#
# see: dh_installdeb(1)

#set -e

# summary of how this script can be called:
#        * <postinst> \`configure\' <most-recently-configured-version>
#        * <old-postinst> \`abort-upgrade\' <new version>
#        * <conflictor\'s-postinst> \`abort-remove\' \`in-favour\' <package>
#          <new-version>
#        * <postinst> \`abort-remove\'
#        * <deconfigured\'s-postinst> \`abort-deconfigure\' \`in-favour\'
#          <failed-install-package> <version> \`removing\'
#          <conflicting-package> <version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

PATH=/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ "${BASEDIR:=/}" != "/" ]; then
    BASEDIR_OPT="-b $BASEDIR"
fi

case "$1" in
    configure)
        %%POSTINST_CONFIGURE%%
    ;;

    abort-upgrade|abort-remove|abort-deconfigure)
    ;;

    *)
        echo "postinst called with unknown argument \'$1\'" >&2
        exit 1
    ;;
esac

# dh_installdeb will replace this with shell code automatically
# generated by other debhelper scripts.

#DEBHELPER#

exit 0
';

# preinst
$$initTemplate{'preinst'} = '#!/bin/sh
# preinst script for sunwcs
#
# see: dh_installdeb(1)

#set -e

# summary of how this script can be called:
#        * <new-preinst> \`install\'
#        * <new-preinst> \`install\' <old-version>
#        * <new-preinst> \`upgrade\' <old-version>
#        * <old-preinst> \`abort-upgrade\' <new-version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

PATH=/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ "${BASEDIR:=/}" != "/" ]; then
    BASEDIR_OPT="-b $BASEDIR"
fi

case "$1" in
    install|upgrade)
    %%PREINST_INSTALL%%
    ;;

    abort-upgrade)
    ;;

    *)
        echo "preinst called with unknown argument \'$1\'" >&2
        exit 1
    ;;
esac

# dh_installdeb will replace this with shell code automatically
# generated by other debhelper scripts.

#DEBHELPER#

exit 0
';


# prerm
$$initTemplate{'prerm'} = '#!/bin/sh
# prerm script for sunwcs
#
# see: dh_installdeb(1)

#set -e

# summary of how this script can be called:
#        * <prerm> \`remove\'
#        * <old-prerm> \`upgrade\' <new-version>
#        * <new-prerm> \`failed-upgrade\' <old-version>
#        * <conflictor\'s-prerm> \`remove\' \`in-favour\' <package> <new-version>
#        * <deconfigured\'s-prerm> \`deconfigure\' \`in-favour\'
#          <package-being-installed> <version> \`removing\'
#          <conflicting-package> <version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

PATH=/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ "${BASEDIR:=/}" != "/" ]; then
    BASEDIR_OPT="-b $BASEDIR"
fi

case "$1" in
    remove|upgrade|deconfigure)
    %%PRERM_UPGRADE%%
    ;;

    failed-upgrade)
    ;;

    *)
        echo "prerm called with unknown argument \'$1\'" >&2
        exit 1
    ;;
esac

# dh_installdeb will replace this with shell code automatically
# generated by other debhelper scripts.

#DEBHELPER#

exit 0
';


# rules
$$initTemplate{'rules'} = '#!/usr/bin/gmake -f
# -*- makefile -*-
# Sample debian/rules that uses debhelper.
# This file was originally written by Joey Hess and Craig Small.
# As a special exception, when this file is copied by dh-make into a
# dh-make output file, you may use that output file without restriction.
# This special exception was added by Craig Small in version 0.37 of dh-make.

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1

MYGATE := ${BASEGATE}
DEST := $(CURDIR)/debian/%%PKGNAME%%

##configure: configure-stamp
##configure-stamp:
##	dh_testdir
	# Add here commands to configure the package.
##	touch configure-stamp


##build: build-stamp
build:

##build-stamp: configure-stamp 
#	dh_testdir
	# Add here commands to compile the package.
#	touch $@

clean:
	dh_testdir
	dh_testroot
	-rm -f build-stamp configure-stamp

	# Add here commands to clean up after the build process.
#	-$(MAKE) clean
#	dh_clean

##install: build
install:
##	dh_testdir
##	dh_testroot
##	dh_clean -k 
##	dh_installdirs

	# Add here commands to install the package into debian/tmp.
#	mkdir -p $(CURDIR)/debian/tmp
#	mv proto/* $(CURDIR)/debian/tmp


# Build architecture-independent files here.
##binary-indep: build install
# We have nothing to do by default.

# Build architecture-dependent files here.
##binary-arch: build install
binary-arch:
	dh_testdir
	dh_testroot
##	dh_installchangelogs 
#	dh_installdocs
#	dh_installexamples
#	dh_install
##	dh_install --sourcedir=$(MYGATE)
	test -f $(CURDIR)/debian/%%PKGNAME%%.fixperms && MYSRCDIR=$(MYGATE) DEST=$(DEST) /bin/sh $(CURDIR)/debian/%%PKGNAME%%.fixperms
##	dh_link
##	dh_compress
#	dh_makeshlibs -p%%PKGNAME%%
	dh_makeshlibs
	dh_installdeb
#	dh_shlibdeps debian/tmp/lib/* debian/tmp/usr/lib/*
	-dh_shlibdeps -Xdebian/sunwcs/usr/kernel/* -- --ignore-missing-info
	dh_gencontrol
	dh_md5sums
	dh_builddeb

##binary: binary-indep binary-arch
binary: binary-arch
##.PHONY: build clean binary-indep binary-arch binary install configure
.PHONY: clean binary-arch binary
';


    return $initTemplate;
}
