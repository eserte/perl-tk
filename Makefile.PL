use Cwd;
use Config;
no  lib '.';
BEGIN 
 {        
  $IsWin32 = ($^O eq 'MSWin32' || $Config{'ccflags'} =~ /-D_?WIN32_?/);

  $VERSION = '800.007';      

  $win_arch = shift @ARGV if @ARGV and $ARGV[0] =~ /^(open32|pm|x|MSWin32)$/;
  require('fix_4_os2.pl'), OS2_massage() if $^O eq 'os2';
  $win_arch = ($IsWin32) ? $^O : 'x'
    if not defined $win_arch; # Currently 'x', 'pm', 'open32', 'MSWin32'

  $win_arch = ($IsWin32) ? 'MSWin32' : 'x';		# Currently 'x' and 'open32' supported

  require "./myConfig";
  use lib ($Tk::MMutil::dir=getcwd);
 }

use Tk::MMutil;

if ($IsWin32)
 {
  *MY::makeaperl = \&makeWin32perl;
  if ($Config{cc} =~ /^gcc/i)
   {
    @libs = ('');
   }
 }
else
 {
  my $plibs = $Config{'libs'};
  my $libs  = "$xlib -lX11 -lpt";
  my @try   = qw(-lsocket -lnsl -lm);
  push(@try,'-lc') if $^O =~ /svr4/i;
  my $lib;
  # perl needs sockets and math library too 
  # so only include these if they made it through perl's Configure
  foreach $lib (@try)
   {
    $libs .= " $lib" if ($plibs =~ /$lib\b/);
   }
  @libs = ("$libs");
 }   

my %dir;
opendir(DIR,'.') || die "Cannot opendir:$!";
foreach my $dir (readdir(DIR))
 {
  next if $dir =~ /^\.\.?$/;
  next if -l $dir;
  next unless -d $dir;
  if (-f "$dir/Makefile.PL")
   {                            
    unless ($win_arch eq 'x')
     {
      $dir{$dir} = 1 unless -f "$dir/NotWin.exc"; 
     }
    else
     {
      $dir{$dir} = 1 unless -f "$dir/NotUnix.exc"; 
     }
   }
 }
closedir(DIR);
delete $dir{'pTk'};

Tk::MMutil::TkExtMakefile(
    'VERSION'  => $VERSION,
    'EXE_FILES' => ['ptksh'],
    'NAME'     => 'Tk',
    'DIR'      => ['pTk',reverse(sort(keys %dir))],
    'DISTNAME' => "Tk",
    'MYEXTLIB' => 'pTk/libpTk$(LIB_EXT)' . ($win_arch =~ /^(open32|pm)$/
					    ? ' pTk/dllInit$(LIB_EXT)'
					    : ''),
    'LIBS'    => \@libs,
    'OBJECT'  => '$(O_FILES)',
#   'PMLIBDIRS'  => ['Tk','pod'],
    'clean'      => { FILES => 'pTk/tkConfig.h Tk/Config.pm' },
    @macro
   );
                           
sub MY::test
  {
    # a) Prevent 'test' target searchs for other tests in subdirs
    # b) Skip regression test if Test.pm is not installed
    package MY;
    my $orig = shift->SUPER::test(@_);
    my $msg = '\n\t--- Test.pm not installed. Grab it from CPAN. ---'
            . '\n\t---      Regression tests skipped.            ---\n\n';
    $orig =~ s/(\ntest ::[^\n]+).*(\ntest_dynamic)/$1\n$2/ms;
    $orig =~ s/runtests \@ARGV/eval {require Test;} ? runtests \@ARGV : print "$msg"/mg;
    return $orig;
  }

sub MY::test_hide {
'
TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)

test :: $(TEST_TYPE)

test_dynamic :: all
	$(PERL) -I$(INST_ARCHLIB) -I$(INST_LIB) demos/widget

test_ : test_dynamic

test_static :: all $(MAP_TARGET)
	./$(MAP_TARGET) -I$(INST_ARCHLIB) -I$(INST_LIB) demos/widget

';
}

sub MY::top_targets
{
 my ($self) = @_;
 my $str = $self->MM::top_targets;
 $str =~ s/\bmanifypods\b/html/g;
# $str =~ s/(pure_all\s*:.*linkext)/$1 tkperl\$(EXE_EXT)/ if $IsWin32;
 return $str;
}

sub MY::post_initialize
{
 my ($self) = @_;
 my ($ret) = '';
 my %files = ();
 my $dir = $self->catdir('$(INST_ARCHLIBDIR)','Tk');
 my $name;
 foreach $name (grep /%$/,keys %{$self->{PM}})
  {
   delete $self->{PM}->{$name};
  }
 delete $self->{PM}->{'Tk/Config.pm'};
 $self->{PM}->{'Tk/Config.pm'} = $self->catfile($dir,'Config.pm');
 # $files{'typemap'} = 1;
 foreach $name ($self->lsdir("."))
  {
   next if ($name =~ /^\./);
   next unless (-f $name);
   $files{$name} = 1 if ($name =~ /\.[tm]$/);
   $files{$name} = 1 if ($name =~ /\.def$/);
  }
 foreach $name (sort(@{$self->{H}},keys %files))
  {
   $self->{PM}->{$name} = $self->catfile($dir,$name);
  }
 if ($IsWin32)
  {
   if ($Config{cc} =~ /^bcc/i) {
     $ret .= "\nRESFILES = pTk\\tk.res\n";
   }
   else {
     push(@{$self->{'O_FILES'}},
          ($Config{'cc'} =~ /^gcc/i) ?
               'pTk\\tkres$(OBJ_EXT)' : 'pTk\\tk.res');
   }
  }
 $ret;
}

sub MY::postamble {
    '

html : subdirs manifypods
	@cd pod && $(MAKE) html $(PASTHRU)

config       :: tkGlue.t tkGlue.m 
	@$(NOOP)

$(BASEEXT)$(OBJ_EXT) : tkGlue.h
Makefile     : myConfig

tkGlue.t     : tkGlue.h pTk/mkVFunc
	$(PERL) pTk/mkVFunc -t $(WINARCH) tkGlue.h

tkGlue.m     : tkGlue.h pTk/mkVFunc
	$(PERL) pTk/mkVFunc -m $(WINARCH) tkGlue.h

$(MYEXTLIB)  : config FORCE
	cd pTk && $(MAKE) 

perlmain.c : config Makefile

pTk/tk.res : $(MYEXTLIB) 

basic      : $(INST_DYNAMIC) pm_to_blib 

MANIFEST : MANIFEST.SKIP $(FIRST_MAKEFILE)
	$(MAKE) manifest 

';
}


