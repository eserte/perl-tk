use ExtUtils::MakeMaker qw(%att &WriteMakefile);

$Version = '1.0';

$inc    = "";
$xlib   = "";
require '../myConfig.out';
require '../MMutil';


# The existence of the ./*/Makefile.PL file causes MakeMaker
# to automatically include Makefile code for the targets
#	config, all, clean, realclean and */Makefile
# which perform the corresponding action in the subdirectory.
                           
WriteMakefile(
    'NAME'     => 'Tk::Pixmap',
    'VERSION'  => $Version,
    'MYEXTLIB' => 'xpm/libXpm.a',
    'DEFINE'  => $define, 
    'OBJECT'  => '$(O_FILES)',
    'INC'     => "-I../pTk $inc",
    'SKIP'	=> [qw(distclean)]
);

sub MY::post_constants {
 my @m;
 push @m, "
.SUFFIXES:
.SUFFIXES:     .a .o .c .xs
";
 push @m, &upgrade_pic();
 join "", @m;
}




sub MY::postamble {
join('',`cat *.d`) . '
Makefile : ../myConfig.out
$(INST_DYNAMIC): ../pTk/libpTk.a

$(MYEXTLIB)  : FORCE
	cd xpm; $(MAKE) libXpm.a

';
}


