use Cwd;
use Config;
no  lib '.';
BEGIN 
 {        
  $IsWin32 = ($^O eq 'MSWin32' || $Config{'ccflags'} =~ /-D_?WIN32_?/);

  $VERSION = '800.006';

  $win_arch = ($IsWin32) ? 'MSWin32' : 'x';		# Currently 'x' and 'open32' supported

  require "./myConfig";
  use lib ($Tk::MMutil::dir=getcwd);
 }

use Tk::MMutil;

if ($IsWin32)
 {
  *MY::makeaperl = \&makeWin32perl;
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
    $dir{$dir} = 1 unless ($IsWin32 && -f "$dir/NotWin.exc"); 
   }
 }
closedir(DIR);
delete $dir{'pTk'};

Tk::MMutil::TkExtMakefile(
    'VERSION'  => $VERSION,
    'NAME'     => 'Tk',
    'DIR'      => ['pTk',reverse(sort(keys %dir))],
    'DISTNAME' => "Tk",
    'MYEXTLIB' => 'pTk/libpTk$(LIB_EXT)' . ($win_arch eq 'open32'
					    ? ' pTk/dllInit$(LIB_EXT)'
					    : ''),
    'LIBS'    => \@libs,
    'OBJECT'  => '$(O_FILES)',
    'MAP_TARGET' => 'tkperl$(EXE_EXT)',
#   'PMLIBDIRS'  => ['Tk','pod'],
    'clean'      => { FILES => 'pTk/tkConfig.h Tk/Config.pm' },
    @macro
   );
                           
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
 $str =~ s/(pure_all\s*:.*linkext)/$1 tkperl\$(EXE_EXT)/ if $IsWin32;
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
   push(@{$self->{'O_FILES'}},'pTk\tkWin32Dll$(OBJ_EXT)');
   if ($Config{cc} =~ /^bcc/i) {
     $ret .= "\nRESFILES = pTk\\tk.res\n";
   }
   else {
     push(@{$self->{'O_FILES'}},'pTk\tk.res');
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

pTk/tkWin32dll$(OBJ_EXT) : 
	@$(NOOP)

basic      : $(INST_DYNAMIC) pm_to_blib 

MANIFEST : MANIFEST.SKIP $(FIRST_MAKEFILE)
	$(MAKE) manifest 

';
}

sub makeWin32perl
{
    my($self, %attribs) = @_;
    my($makefilename, $searchdirs, $static, $extra, $perlinc, $target, $tmp, $libperl) =
	@attribs{qw(MAKE DIRS STAT EXTRA INCL TARGET TMP LIBPERL)};
    my(@m);
    push @m, "# Tk Win32 makeaperl
MAP_TARGET    = $target
FULLPERL      = $self->{FULLPERL}
";
    return join '', @m if $self->{PARENT};
    $tmp = "." unless $tmp;

    my($dir) = join ":", @{$self->{DIR}};

    my($cccmd, $linkcmd, $lperl);

    # We trust that what has been handed in as argument, will be buildable
    $static = [] unless $static;
    @static{@{$static}} = (1) x @{$static};

    grep(s/^/-I/, @{$perlinc || []});

    $target = "perl" unless $target;

    push @m, "
MAP_LINKCMD   = \$(LD) 
MAP_PERLINC   = @{$perlinc || []}
MAP_STATIC    = winMain\$(OBJ_EXT)

MAP_PRELIBS   = \$(LDLOADLIBS)
";

    if (defined $libperl) {
        $libperl =~ s/libperl/perl/;
	($lperl = $libperl) =~ s/\$\(A\)/$self->{LIB_EXT}/;
    }
    unless ($libperl && -f $lperl) { # Ilya's code...
	my $dir = $self->{PERL_SRC} || "$self->{PERL_ARCHLIB}/CORE";
	$libperl ||= "perl$self->{LIB_EXT}";
	$libperl   = "$dir/$libperl";
	$lperl   ||= "perl$self->{LIB_EXT}";
	$lperl     = "$dir/$lperl";

        if (! -f $libperl and ! -f $lperl) {
          # We did not find a static libperl. Maybe there is a shared one?
          if ($^O eq 'solaris' or $^O eq 'sunos') {
            $lperl  = $libperl = "$dir/$Config::Config{libperl}";
            # SUNOS ld does not take the full path to a shared library
            $libperl = '' if $^O eq 'sunos';
          }
        }

	print STDOUT "Warning: $libperl not found
    If you're going to build a static perl binary, make sure perl is installed
    otherwise ignore this warning\n"
		unless (-f $lperl || defined($self->{PERL_SRC}));
    }


    push @m, "
MAP_LIBPERL = $libperl
MAP_LDFLAGS = \$(LDFLAGS) -subsystem:windows
";

push (@m, "
$tmp/perlmain\$(OBJ_EXT): $tmp/perlmain.c
	cd $tmp && \$(CCCMD) -I\$(PERL_INC) perlmain.c\n");

    push @m, qq{
$tmp/perlmain.c: $makefilename}, q{
	}.$self->{NOECHO}.q{echo Writing $@
	}.$self->{NOECHO}.q{$(PERL) $(MAP_PERLINC) -MExtUtils::Miniperl \\
		-e "writemain(grep s#.*/auto/##, qw|$(MAP_STATIC)|)" > $@t && $(MV) $@t $@

};

    push @m,"
\$(MAP_TARGET) :: $tmp/perlmain\$(OBJ_EXT) \$(MAP_LIBPERL) \$(MAP_STATIC) 
".( $Config{cc} =~ /^bcc/i ?	# Borland
"	\$(LD) -Tpe -aa \$(LDFLAGS) c0w32\$(OBJ_EXT) \\
	    $tmp\\perlmain\$(OBJ_EXT) \$(MAP_STATIC:s,/,\\,),\$\@,, \\
	    \$(MAP_LIBPERL:s,/,\\,) \$(MAP_PRELIBS:s,/,\\,)
" : $Config{cc} =~ /^gcc/i ?	# GCC
"	\$(LD) -mwindows -o \$\@ \$(LDFLAGS) $tmp/perlmain\$(OBJ_EXT) \\
	    \$(MAP_STATIC) \$(MAP_LIBPERL) \$(MAP_PRELIBS)
" :				# VC
"	\$(LD) -subsystem:windows -out:\$\@ \$(LDFLAGS) $tmp/perlmain\$(OBJ_EXT) \\
	    \$(MAP_STATIC) \$(MAP_LIBPERL) \$(MAP_PRELIBS)
");


    push @m, q{
inst_perl: pure_inst_perl doc_inst_perl

pure_inst_perl: $(MAP_TARGET)
	}.$self->{CP}.q{ $(MAP_TARGET) }.$self->catfile('$(INSTALLBIN)','$(MAP_TARGET)').q{

clean :: map_clean

map_clean :
	}.$self->{RM_F}.qq{ $tmp/perlmain\$(OBJ_EXT) $tmp/perlmain.c \$(MAP_TARGET) 
};

    join '', @m;

}
