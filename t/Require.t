#!perl -w
BEGIN { $ENV{'PERL_DL_NONLAZY'} = 1 }
require Tk;
# $SIG{__WARN__} = sub { die shift };
my ($dir) = $INC{'Tk.pm'} =~ /^(.*)\.pm$/;
opendir(TK,$dir) || die "Cannot opendir $dir:$!";
my @files = grep(/\.pm$/,readdir(TK));
closedir(TK);
my $file;
print "1..",scalar(@files),"\n";
my $count = 1;
foreach $file (@files)
 {
  if ($file =~ /\.pm$/)
   {
    # print "Tk/$file\n";
    eval { require "Tk/$file" };
    if ($@)
     {
      warn "Tk/$file: $@";
      print "not ";
     }
    print "ok ",$count++,"\n";
   }
 }

foreach my $path (sort grep /^Tk.*\.pm$/,keys %INC)
 {
  my $mod = $path;
  $mod =~ s#/#::#g;
  $mod =~ s#\.pm$##;
  next unless defined %{$mod.'::'};
  die "No VERSION in $mod\n" unless defined ${$mod.'::VERSION'};
  print "$mod = ",${$mod.'::VERSION'},"\n";
 }

