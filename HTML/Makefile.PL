
use Tk::MMutil;

my @missing = ();

my $pkg;
foreach $pkg (qw(URI::URL HTML::Parse))
 {
  { eval "package dummy; require $pkg"; }
  push(@missing,$pkg) if ($@);
 }

if (@missing)
 {
  print "Following modules are required but not installed:\n",
        join("\n",@missing),"\n";
 }

Tk::MMutil::TkExtMakefile(
      'EXE_FILES' => ['tkweb'],
      'PREREQ'    => { URI::URL => 0, HTML::Parse => 0 },
      'linkext' => { LINKTYPE => ''}
      );


