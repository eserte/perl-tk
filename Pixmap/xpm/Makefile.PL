use Config;
use ExtUtils::MakeMaker;

# The existence of the ./pTk/Makefile.PL file causes MakeMaker
# to automatically include Makefile code for the targets
#	config, all, clean, realclean and sdbm/Makefile
# which perform the corresponding action in the subdirectory.



use Tk::Config;
use Tk::MMutil;

Tk::MMutil::TkExtMakefile(
    'LINKTYPE'  => 'static',
    'INC'	=> "$inc -I.",
    'OBJECT'    => '$(O_FILES)',
    'SKIP'	=> [qw(dynamic dynamic_lib distclean 
                       test perldepend xs_c xs_o)],
    'clean'	=> {'FILES' => 'libXpm$(LIB_EXT) *%'}
);

sub MY::install {
'
install :: all
';
}

sub MY::top_targets {
'
all     :: static

dynamic :: static 

config  ::

';
}

sub MY::post_constants
{
 '
INST_STATIC=libXpm$(LIB_EXT)
';
}

sub MY::realclean {
	'
realclean :: clean
	rm -f Makefile
';
}



