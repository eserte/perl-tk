use Tk::MMutil;
use Config;

if ($^O eq 'MSWin32')
 {
  *MY::makeaperl = \&win32_makeaperl;
 }
else
 {
  *MY::makeaperl = \&unix_makeaperl;
 }

Tk::MMutil::TkExtMakefile(
 MAP_TARGET => '$(INST_BIN)/guiperl$(EXE_EXT)',
 LINKTYPE   => 'static',
 OBJECT     => '$(O_FILES)',
 SKIP       => qw[static_lib],
 MAKEAPERL  => 1
);

sub MY::postamble 
{
"
all :: \$(MAP_TARGET)
	$self->{NOECHO}\$(NOOP)
";
}


sub MY::top_targets
{
 my $self=shift;
 local $_ = $self->MM::top_targets(@_);
 my $dir = $self->catfile('$(INST_BIN)','.exists');
 $_ .= "
config :: $dir
	$self->{NOECHO}\$(NOOP)
";
 $_ .= $self->dir_target(qw[$(INST_BIN)]);
 return $_;
}

sub unix_makeaperl
{
 my $self=shift;
 local $_ = $self->MM::makeaperl(@_);
 unless (s/(\n\t\$\(MAP_LINKCMD\)[^\n]*?\n).*?\n\n/$1/s)
  {
   die $_;
  }
 return $_;
}

sub win32_makeaperl
{
    my($self, %attribs) = @_;
    my($makefilename, $searchdirs, $static, $extra, $perlinc, $target, $tmp, $libperl) =
	@attribs{qw(MAKE DIRS STAT EXTRA INCL TARGET TMP LIBPERL)};
    my(@m);
    push @m, "# Tk Win32 makeaperl
MAP_TARGET    = \$(INST_BIN)\\guiperl\$(EXE_EXT)
FULLPERL      = $self->{FULLPERL}
";
    $tmp = "." unless $tmp;

    my($dir) = join ":", @{$self->{DIR}};

    my($cccmd, $linkcmd, $lperl);

    # We trust that what has been handed in as argument, will be buildable
    $static = [] unless $static;
    @static{@{$static}} = (1) x @{$static};

    grep(s/^/-I/, @{$perlinc || []});

    push @m, "
MAP_PERLINC   = @{$perlinc || []}
MAP_STATIC    = winMain\$(OBJ_EXT)

MAP_PRELIBS   = \$(LDLOADLIBS)
MAP_LIBPERL = \$(PERL_ARCHIVE)
";      

    push @m,"
\$(MAP_TARGET) :: \$(MAP_LIBPERL) \$(MAP_STATIC) 
".( $Config{cc} =~ /^bcc/i ?	# Borland
"	\$(LD) -Tpe -aa \$(LDFLAGS) c0w32\$(OBJ_EXT) \\
	     \$(MAP_STATIC:s,/,\\,),\$\@,, \\
	    \$(MAP_LIBPERL:s,/,\\,) \$(MAP_PRELIBS:s,/,\\,)
" : $Config{cc} =~ /^gcc/i ?	# GCC
"	\$(LD) -v -mwindows -o \$\@ \$(LDFLAGS)  \\
	    \$(MAP_STATIC) \$(MAP_LIBPERL) \$(MAP_PRELIBS)
" :				# VC
"	\$(LD) -subsystem:windows -out:\$\@ \$(LDFLAGS)  \\
	    \$(MAP_STATIC) \$(MAP_LIBPERL) \$(MAP_PRELIBS)
");

 join '', @m;
}

