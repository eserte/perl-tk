#!perl -w
use strict;
use warnings;
use Test::More;
BEGIN { $ENV{'PERL_DL_NONLAZY'} = 1 }

my @warnings;
$SIG{__WARN__} = sub { push @warnings, @_ };

require Tk;
my ($dir) = $INC{'Tk.pm'} =~ /^(.*)\.pm$/;
opendir(TK,$dir) || die "Cannot opendir $dir:$!";
my @files = grep(/\.pm$/,readdir(TK));
closedir(TK);

plan tests => 1 + @files;

for my $file (@files)
 {
  if ($file =~ /\.pm$/)
   {
    eval { require "Tk/$file" };
    ok !$@, "Tk/$file compiled" or diag $@;
   }
 }

is_deeply \@warnings, [], 'no warnings';
