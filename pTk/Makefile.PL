use Config;
use ExtUtils::MakeMaker;

$define = "-DTK_LIBRARY=\\\"$Config{'privlib'}/Tk\\\"";
$inc    = "";
# The existence of the ./pTk/Makefile.PL file causes MakeMaker
# to automatically include Makefile code for the targets
#	config, all, clean, realclean and sdbm/Makefile
# which perform the corresponding action in the subdirectory.

require '../myConfig.out';
require '../MMutil';

if (&try_compile("config/signedchar.c"))
 {
  $define .= " -DANSI_SIGNED_CHAR";
 }
else
 {
  if (&try_run("config/unsigned.c"))
   {
    $define .= " -DCHAR_UNSIGNED";
   }
 }

$inc .= " -I." ; 

WriteMakefile(
    'LINKTYPE'  => 'static',
    'DEFINE'	=> $define,
    'INC'	=> $inc,
    'SKIP'	=> [qw(static static_lib dynamic dynamic_lib distclean 
                       test perldepend dist makeaperl xs_o)],
    'clean' 	=> {'FILES' => 'libpTk.a *%'}
);

sub MY::xs_c {
'
# Rules for building .t table files from .h files
.SUFFIXES:
.SUFFIXES: .a .o .c .xs .t .h 

.h.t :
	$(PERL) mkVFunc $< 
'
}

sub MY::post_constants {

my $objects = "LIBOBJS =";
unless (defined($Config{'i_stdlib'}) && &try_compile("config/Hstrtoul.c"))
 {
  $objects .= " strtoul.o" 
 }
my $len     = length($objects);
foreach (<[LXt]*.c>)
{
 s/\.c/.o/;
 if (($len+length($_)+1) > 72)
  {
   $objects .= "\\\n\t";
   $len = 8;
  }
 $objects .= " $_";
 $len     += 1+length($_);
} 
$objects .= "\n";

return "\n" . $objects . &upgrade_pic();
};

sub MY::install {
'
install :: all
';
}

sub MY::top_targets {
'
all     :: static 

static  ::	libpTk.a 

dynamic ::	libpTk.a 

libpTk.a: $(LIBOBJS) 
	ar cr libpTk.a $(LIBOBJS)
	$(RANLIB) libpTk.a

$(LIBOBJS): $(HDRS)


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
Makefile : ../myConfig.out

Lang.t  : Lang.h   mkVFunc
tk.t    : tk.h     mkVFunc
tkInt.t : tkInt.h  mkVFunc
Xlib.t  : Xlib.h   mkVFunc
tkImgPhoto.t  : tkImgPhoto.h   mkVFunc

config :: Lang.t tk.t tkInt.t tkImgPhoto.t

';
}


