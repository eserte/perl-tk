#!/usr/local/bin/nperl -w
use File::Find;
use File::Basename;

my %skip;
my %files;

sub wanted
{
 my $s = $File::Find::name;
 $s =~ s#^\./##;
 $files{$s} = 1 if (-f $_);
 if (/\.xs$/)
  {
   $s =~ s#\.xs$#.c#;
   $skip{$s} = 1;
  }
 if ($s =~ m#^(.*)/mTk/.*?([^/]+\.[ch])$#x)
  {
   $skip{"$1/$2"} = 1 unless ($_ eq 'Xlib.h');
  }
}

find(\&wanted,'.');

chmod(0666,"MANIFEST.SKIP");
open(SKIP,">MANIFEST.SKIP") || die "Cannot open MANIFEST.SKIP:$!";
print SKIP <<'EOF'
\.[oaid]$
\.(bso?|old|bak|out|hide|q4|gz|tcl|orig)$
^\.
/\.
C\+\+/Main$
\bcore$
\bConfig.pm$
\bpTk/tkConfig\.h$
\bpTk/need$
\bpm_to_blib$
[%~]$
\b(blib|merge|Ilya|Pixmap)/
\bTix/
tcl\.pm$
\bcore\b
\bToDo/
\bObsolete/
\b(GNU)?[Mm]akefile(\.aperl)?$
\btkperl\b
\bHTML/doc\b
extralibs\.ld
doc/index\.html$
doc/MANFILES$
doc/.*\.htm$
myConfig\.out
\bswapm$
bin/patchls$
EOF
;
foreach (sort keys %skip)
 {
  s#\.#\\.#;
  print SKIP "$_\$\n";
 }
close(SKIP);
