use strict;
use Tk::MMutil;
use Tk::Config ();
use Tk::MMtry;
use File::Copy;

my $l = $Config::Config{'lib_ext'};
my $cc = $Config::Config{'cc'};
my $zlib = "libz$l";

foreach my $file (qw(zlib/Makefile.PL libpng/Makefile.PL))
 {
  chmod(0666,$file) unless -w $file;
  unlink($file);
 }

if ($Tk::MMtry::VERSION ge '4.007' &&
    try_run("config/has_png.c",['-I/usr/local/include'],['-lpng -lz -lm']))
 {
  Tk::MMutil::TkExtMakefile(
       NAME         => 'Tk::PNG',
       VERSION_FROM => 'PNG.pm',
       XS_VERSION   => $Tk::Config::VERSION,
       dist         => { COMPRESS => 'gzip -f9', SUFFIX => '.gz' },
       OBJECT       => '$(O_FILES)',
       INC          => '-I/usr/local/include',
       LIBS         => ['-lpng -lz -lm'],
     );
 }
else
 {
  my $ok = 1;
  foreach my $file ("libpng/Makefile.PL","zlib/Makefile.PL")
   {
    next unless -f $file;
    chmod(0666,$file);
    unlink($file);
   }
  unless (copy("libpng/Makefile.maybe","libpng/Makefile.PL"))
   {
    warn "Cannot copy libpng/Makefile.maybe => libpng/Makefile.PL ($!)";
    $ok = 0;
   }
  unless (copy("zlib/Makefile.maybe","zlib/Makefile.PL"))
   {
    warn "Cannot copy zlib/Makefile.maybe => zlib/Makefile.PL ($!)";
    $ok = 0;
   }
  if ($ok)
   {
    warn "Building libpng$l\n";
    my $extlib = "libpng/libpng$l";
    if ($cc eq 'cl')
     {
      $extlib .= " zlib/zlib$l";
      $zlib   = "zlib$l";
     }
    else
     {
      $extlib .= " zlib/libz$l";
     }
    Tk::MMutil::TkExtMakefile(
           NAME         => 'Tk::PNG',
           VERSION_FROM => 'PNG.pm',
           XS_VERSION   => $Tk::Config::VERSION,
           dist         => { COMPRESS => 'gzip -f9', SUFFIX => '.gz' },
           OBJECT       => '$(O_FILES)',
           INC          => '-Ilibpng -Izlib',
           MYEXTLIB     => $extlib,
           LIBS         => ['-lm'],
         );
    }
   else
    {
     warn "Cannot build libpng$l\n";
     ExtUtils::MakeMaker::WriteEmptyMakefile();
    }
 }

package MY;

sub pasthru {
  qq[PASTHRU="CC=$Config::Config{cc} $Config::Config{cccdlflags}" RANLIB=\"$Config::Config{ranlib}\"];
}

sub postamble {
  my $s = '';
  if (-f "libpng/Makefile.PL")
   {
    $s .=
"
libpng/libpng$l : zlib/$zlib
	cd libpng && \$(MAKE) libpng".$l.' $(PASTHRU)
';

   }
  if (-f "zlib/Makefile.PL")
   {
    $s .=
"
zlib/$zlib : FORCE
	cd zlib && \$(MAKE) $zlib".' $(PASTHRU)
';

   }
 return $s;
}




