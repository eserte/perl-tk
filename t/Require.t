#!perl -w
use Tk;
$SIG{__WARN__} = sub { die shift };
my ($dir) = $INC{'Tk.pm'} =~ /^(.*)\.pm$/;
opendir(TK,$dir) || die "Cannot opendir $dir:$!";
my $file;
foreach $file (readdir(TK))
 {
  if ($file =~ /\.pm$/)
   {
    require "Tk/$file";
   }
 }
closedir(TK);
