use ExtUtils::MakeMaker;

# The existence of this Makefile.PL file causes MakeMaker
# to automatically include Makefile code for the targets
#	config, all, clean, realclean and sdbm/Makefile
# which perform the corresponding action in the subdirectory.
                           
$xlib   = "";
$inc    = "";

require '../myConfig.out';
require '../MMutil';

WriteMakefile( 'NAME'   => 'Tk::Xlib',
               'SKIP'	=> [qw(distclean)],
	       'dynamic_lib' => { OTHERLDFLAGS => '../pTk/libpTk.a'},
               'DEFINE'  => $define, 
               'INC'     => "-I../pTk $inc"
             );

sub MY::post_constants {
return &upgrade_pic();
}

sub MY::postamble {
join('',`cat *.d`) . '
Makefile     : ../myConfig.out
$(BASEEXT).c : ../typemap 
$(INST_DYNAMIC): ../pTk/libpTk.a

';
}


