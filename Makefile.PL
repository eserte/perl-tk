use Cwd;
no  lib '.';
BEGIN 
 {
  $VERSION = '400.201';
  require "./myConfig";
  use lib ($Tk::MMutil::dir=getcwd);
 }

use Tk::MMutil;

Tk::MMutil::TkExtMakefile(
    'VERSION'  => $VERSION,
    'NAME'     => 'Tk',
    'DISTNAME' => "Tk",
    'MYEXTLIB' => 'pTk/libpTk$(LIB_EXT)',
    'LIBS'    => ["$xlib -lX11 -lpt -lsocket -lnsl -lm"],
    'OBJECT'  => '$(O_FILES)',
    'MAP_TARGET' => 'tkperl',
    'clean'      => { FILES => 'pTk/tkConfig.h Tk/Config.pm' },
    @macro
   );
                           
sub MY::test {
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
 return $str;
}

sub MY::post_initialize
{
 my ($self) = @_;
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
 '';
}

sub MY::postamble {
    '

html : subdirs manifypods
	@cd doc && $(MAKE) html $(PASTHRU)

config       :: tkGlue.t

$(BASEEXT)$(OBJ_EXT) : tkGlue.h
tkGlue$(OBJ_EXT)     : tkGlue.c tkGlue.h pTk/Methods.def tkGlue.t
Makefile     : myConfig

tkGlue.t     : tkGlue.h pTk/mkVFunc
	$(PERL) pTk/mkVFunc tkGlue.h

$(MYEXTLIB)  : config FORCE
	cd pTk; $(MAKE) 

perlmain.c : config Makefile

pTk/Methods.def : $(MYEXTLIB)

';
}


