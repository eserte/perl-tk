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
\.(bso?|old|bak|bck|base|exp|broke|out|hide|q4|gz|tcl|rtf|orig)$
^\.
/\.
C\+\+/Main$
\bcore$
\bConfig.pm$
\bpTk/tkConfig\.h$
\bpTk/(need|canvas_sources)$
\b(pm_to_blib|perl|wedge|efdebug)$
[%~]$
\b(blib|merge|Ilya|Pixmap|patches|pod2)/
\bTix/
tcl\.pm$
\bcore\b
Canvas/diag\.txt$
pod/html$
\bdoc/
Tk.ppd$
\b(ToDo|learn|Pending|Obsolete)/
\b(GNU)?[Mm]akefile(\.aperl)?$
-bug$
\bperlmain\.c$
\btkperl\b
\bHTML/doc\b
\bEvent/Play\b
\bEvent/fe
pod/tkman.ps$
extralibs\.ld
doc/index\.html$
doc/MANFILES$
doc/.*\.htm$
myConfig\.out
\.todo$
\bswapm$
bin/patchls$
prep_rel$
EOF
;
foreach (sort keys %skip)
 {
  s#\.#\\.#;
  print SKIP "$_\$\n";
 }
close(SKIP);
