use Config;
use ExtUtils::MakeMaker;

$define = "";
$inc    = "";
# The existence of the ./pTk/Makefile.PL file causes MakeMaker
# to automatically include Makefile code for the targets
#	config, all, clean, realclean and sdbm/Makefile
# which perform the corresponding action in the subdirectory.

require '../../myConfig.out';
require '../../MMutil';

$inc .= " -I." ; 

WriteMakefile(
    'LINKTYPE'  => 'static',
    'DEFINE'	=> $define,
    'INC'	=> $inc,
    'SKIP'	=> [qw(static static_lib dynamic dynamic_lib distclean 
                       test perldepend xs_c xs_o)],
    'clean' 	=> {'FILES' => 'libXpm.a *%'}
);

sub MY::post_constants {
 return &upgrade_pic();
}

#'LIBOBJS= data.o create.o misc.o rgb.o scan.o parse.o hashtab.o \
#      WrFFrP.o RdFToP.o CrPFrDat.o CrDatFrP.o \
#      WrFFrI.o RdFToI.o CrIFrDat.o CrDatFrI.o \
#      CrIFrBuf.o CrPFrBuf.o CrBufFrI.o CrBufFrP.o \
#      RdFToDat.o WrFFrDat.o \
#      Attrib.o CrIFrP.o CrPFrI.o Image.o Info.o RdFToBuf.o WrFFrBuf.o

sub MY::install {
'
install :: all
';
}

sub MY::top_targets {
'
all :: linkext

static  ::	libXpm.a

dynamic ::	libXpm.a

libXpm.a: $(O_FILES)
	ar cr libXpm.a $(O_FILES)
	$(RANLIB) libXpm.a

config ::

';
}

sub MY::realclean {
	'
realclean :: clean
	rm -f Makefile
';
}

sub MY::postamble {
join('',`cat *.d`) . '
Makefile : ../../myConfig.out
';
}



