use ExtUtils::MakeMaker qw(%att &WriteMakefile);

$Version = 'b9';

$define = '-DBASEEXT=\\"$(BASEEXT)\\"';
$define .= " -DNTK_VERSION=\\\"$Version\\\"";
$inc    = "";
$xlib   = "";
require './myConfig';
require './MMutil';

# The existence of the ./*/Makefile.PL file causes MakeMaker
# to automatically include Makefile code for the targets
#	config, all, clean, realclean and */Makefile
# which perform the corresponding action in the subdirectory.
                           
WriteMakefile(
    'NAME'     => 'Tk',
    'DISTNAME' => "Tk",
    'VERSION'  => $Version,
    'MYEXTLIB' => 'pTk/libpTk.a',
    'DEFINE'  => $define, 
    'INC'     => $inc,
#   'PM'      => $pm,
    'OBJECT'  => '$(BASEEXT).o tkGlue.o leak_util.o',
    'LIBS'    => ["$xlib -lX11 -lpt -lsocket -lnsl -lm"],
    'clean' 	=> {'FILES' => 'libpTk.a *%'},
    'MAP_TARGET' => 'tkperl'
);

sub Hide::staticmake {
    my($self, %attribs) = @_;
    my $rules = "";

    my(%searchdirs)=($att{PERL_ARCHLIB} => 1,  $att{INST_ARCHLIB} => 1);
    my(@searchdirs)=keys %searchdirs;
    # And as it's not yet built, we add the current extension
    my(@static)  = ();
    my $name;
    foreach $name ("$att{BASEEXT}.xs",<*/*.xs>)
     {
      $name =~ s/\.xs$/\.a/;
      my $dep = "\$(INST_ARCHLIB)/auto/$att{FULLEXT}/$name";
      push(@static,$dep);
      $rules .= "$dep : ";
      $rules .= (($name =~ m#/#) ? "subdirs" : 'config') . "\n\n";
     }
 
    my(@perlinc) = ($att{INST_ARCHLIB}, $att{INST_LIB}, $att{PERL_ARCHLIB}, $att{PERL_LIB});
    $rules .= MY->makeaperl('MAKE' => $att{MAKEFILE}, 
			     'DIRS' => \@searchdirs, 
			     'STAT' => \@static, 
			     'INCL' => \@perlinc,
			     'TARGET' => $att{MAP_TARGET},
			     'TMP' => "",
			     'LIBPERL' => $att{LIBPERL_A}
			     );
   $rules; 
}


sub Hide::post_initialize {
 my $dir = `pwd`;
 chomp($dir);
 while (($key,$val) = each %att)
  {
   if (defined $val && $val =~ m#^\./blib$#)
    {
     $val =~ s,\./,$dir/,;
     $att{$key} = $val;
    }
  }
 "# MM version $ExtUtils::MakeMaker::Version\n";
}


sub MY::post_constants {
 my @m;
 push @m, "
.SUFFIXES:
.SUFFIXES:     .a .o .c .xs
";
 push @m, &upgrade_pic();
 join "", @m;
}


sub MY::test {
'
test : all
	$(PERL) -I$(INST_ARCHLIB) -I$(INST_LIB) demos/widget
';
}

sub MY::postamble {
    '
subdirs      :: $(MYEXTLIB) 
config       :: tkGlue.t

Makefile     : myConfig
$(BASEEXT).o : tkGlue.h
tkGlue.o     : tkGlue.c tkGlue.h pTk/Methods.def tkGlue.t


tkGlue.t     : tkGlue.h pTk/mkVFunc
	$(PERL) pTk/mkVFunc tkGlue.h

$(MYEXTLIB)  : config FORCE
	cd pTk; $(MAKE) libpTk.a

perlmain.c : config Makefile

pTk/Methods.def : $(MYEXTLIB)

installpm   :: $(INST_PM)

';
}

sub Hide::installpm_x { # called by installpm per file
    my($self, $dist, $inst, $splitlib) = @_;
    warn "Warning: Most probably 'make' will have problems processing this file: $inst\n"
	if $inst =~ m![:#]!;
    my($instdir) = $inst =~ m|(.*)/|;
    my(@m);
    push(@m,"
$inst: $dist $att{MAKEFILE} $instdir/.exists
".'	@ '.$att{RM_F}.' $@
	'."$att{CP} $dist".' $@
	@echo $@ >> $(INST_ARCHAUTODIR)/.packlist
');
    push(@m, "\t\@\$(AUTOSPLITFILE) \$@ $splitlib/auto\n")
	if ($splitlib and $inst =~ m/\.pm$/);

    push @m, MM->dir_target($instdir);
    join('', @m);
}


