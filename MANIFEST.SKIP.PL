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

open(SKIP,">MANIFEST.SKIP") || die "Cannot open MANIFEST.SKIP:$!";
print SKIP <<'EOF'
\.[oai]$
\.(bso?|old|bak|out|hide|q4)$
^\.
/\.
C\+\+/Main$
\bcore$
\bConfig.pm$
\bpTk/tkConfig\.h$
\bpTk/need$
\bpm_to_blib$
%$
\b(blib|merge)/
\bTix/
tcl\.pm$
\bcore\b
\bToDo/
\bObsolete/
Makefile$
Makefile\.aperl$
\btkperl\b
\bHTML/doc\b
extralibs\.ld
doc/index\.html$
doc/MANFILES$
doc/.*\.htm$
myConfig\.out
EOF
;
foreach (sort keys %skip)
 {
  s#\.#\\.#;
  print SKIP "$_\$\n";
 }
close(SKIP);
