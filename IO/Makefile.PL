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
    'NAME'     => 'Tk::IO',
    'VERSION'  => $Version,
    'DEFINE'  => $define, 
    'OBJECT'  => '$(O_FILES)',
    'INC'     => "-I../pTk $inc",
    'SKIP'	=> [qw(distclean)]
);

sub MY::post_constants {

 return &upgrade_pic();
}

sub MY::postamble {
join('',`cat *.d`) . '
Makefile     : ../myConfig.out
$(INST_DYNAMIC): ../pTk/libpTk.a

';
}


