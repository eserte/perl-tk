use Config;
use ExtUtils::MakeMaker;

use Tk::MMtry qw(try_compile);
use Tk::MMutil;
use Tk::Config;

if ($win_arch eq 'open32') {
  $inc .= " -I$toolkit/H -Imtk/open32/h";
}

Tk::MMutil::TkExtMakefile(
    'NAME'	=> 'Tk::pTk',
    'VERSION'	=> $Tk::Config::VERSION,
    'LINKTYPE'	=> 'static',
    'OBJECT'	=> '$(O_FILES)', 
    macro	=> { WINARCH     => $win_arch },
    'DEFINE'	=> $define,
    'INC'	=> "$inc -I. -Ibitmaps",
    'SKIP'	=> [qw( distclean test dist makeaperl xs_o)],
    'clean'	=> {'FILES' => 'libpTk$(LIB_EXT) *%'}
);

sub MY::xs_c {
'
# Rules for building .t table files from .h files
.SUFFIXES: .t .h 
.h.t :
	$(PERL) mkVFunc $(WINARCH) $< 
'
}

sub MY::post_initialize
{
 my ($self) = @_;
 my %mTk;
 my $dir;
 my @list;
 if ($^O eq 'MSWin32')
  {
   @list = qw(win xlib generic tix tclWin tclGeneric);
  }
 else
  {
   @list = qw(unix generic tix tclUnix tclGeneric );
  }
 print STDERR "Generating Dependencies for $^O\n";
 foreach $dir (@list)
  {
   my %exc;
   my $src = $self->catdir("mTk",$dir);
   next unless -d $src;
   opendir(DIR,$src) || die "Cannot open $src:$!";
   if (open(EXC,$self->catfile($src,"pTk.exc")))
    {
     while (<EXC>)
      {
       chomp;
       $exc{$_} = 1;
       if (-f $_)
        {
         chmod(0777,$_);
         unlink($_); 
         warn "Loose $_\n";
        }
      }
     close(EXC);
    }
   else
    {
     warn "Cannot open $src/pTk.exc:$!";
    }
   my $file;
   while (defined($file = readdir(DIR)))
    {
     next if $exc{$file};
     if ($file =~ /\.[ch]$/)
      {
       $mTk{$file} = $self->catfile($src,$file) unless (exists $mTk{$file});
      }
    }
   closedir(DIR);
  }
 my @loose = ();
 if (defined($Config{'i_stdlib'}) && try_compile("config/Hstrtoul.c"))
  {
   push(@loose,'strtoul.c');
  }
 if (defined($Config{'i_string'}) && try_compile("config/Hstrdup.c"))
  {
   push(@loose,'strdup.c');
  }
 if (try_compile("config/Hstrcasecmp.c"))
  {
   push(@loose,'strcasecmp.c');
  }
 $self->Tk::MMutil::mTk_CHO(\%mTk,@loose);
 my %files = ();
 my $name;
 $self->{'dir_targets'} = [];
 $dir = $self->catdir('$(INST_ARCHLIBDIR)','pTk');
 push(@{$self->{'dir_targets'}},$dir);
 foreach $name ($self->lsdir("."))
  {
   next if ($name =~ /^\./);
   next unless (-f $name);
   $files{$name} = 1 if ($name =~ /\.[tm]$/);
  }
 foreach $name (sort(@{$self->{H}},keys %files))
  {
   $self->{PM}->{$name} = $self->catfile($dir,$name);
  }
 if ($^O eq 'MSWin32')
  {my $ddir = $self->catdir('$(INST_ARCHLIBDIR)','X11');
   my $sdir = $self->catdir('mTk','xlib','X11');
   push(@{$self->{'dir_targets'}},$ddir);
   foreach $name ($self->lsdir($sdir))
    {
     next if $name =~ /^\.+$/;
     my $src = $self->catfile($sdir,$name);
     next unless -f $src;
     $self->{PM}->{$src} = $self->catfile($ddir,$name);
    }
  }
 $dir = $self->catdir($dir,"compat");
 push(@{$self->{'dir_targets'}},$dir);
 foreach $name ($self->lsdir("compat"))
  {
   next if $name =~ /^\.+$/;
   my $src = $self->catfile('compat',$name);
   next unless -f $src;
   $self->{PM}->{$src} = $self->catfile($dir,$name);
  }
 '';
}

sub MY::post_constants 
{
 '
INST_STATIC=libpTk$(LIB_EXT)
';
};

sub MY::install {
'
install :: all
';
}

sub MY::dynamic_lib { my $self = shift; "dynamic_lib : static_lib\n\t".$self->{'NOECHO'}."\$(NOOP)\n" }

sub MY::dynamic     { my $self = shift; "dynamic : static\n\t".$self->{'NOECHO'}."\$(NOOP)\n" }

sub MY::static 
{
  my $self = shift;
  my $str  = $self->MM::static(@_);
  if ($win_arch eq 'open32')
   {
    $str .= '
static :: dllInit$(LIB_EXT)
dllInit$(LIB_EXT): dllMain$(OBJ_EXT)
	$(AR) $(AR_STATIC_ARGS) $@ dllMain$(OBJ_EXT) && $(RANLIB) $@
';
   }
 return $str; 
}

sub MY::realclean {
  my $self = shift;
  my $str  = $self->MM::realclean(@_);
  $str .= "\t\$(RM_F) ".join(" \\\n\t",keys %{$self->{'MTK'}})."\n";
  return $str;
}


sub MY::postamble {
my $self = shift;
my $dep = $self->Tk::MMutil::mTk_postamble;

$dep .= $self->dir_target(@{$self->{'dir_targets'}}); 

$dep .= "config :: " . join(" \\\n\t",map($self->catfile($_,".exists"),@{$self->{'dir_targets'}})) .
        "\n\t".$self->{NOECHO}."\$(NOOP)\n";

if ($^O eq 'MSWin32')
 {
  $dep .= '
tk.res : mTk/win/rc/tk.rc
	rc -fo $@ -r -i . mTk\win\rc\tk.rc
libpTk$(LIB_EXT) : tk.res
';
 } 
$dep . '
Lang.t  : Lang.h  Lang.exc  mkVFunc
tk.t    : tk.h    tk.exc    mkVFunc
tkInt.t : tkInt.h tkInt.exc mkVFunc
tkImgPhoto.t  : tkImgPhoto.h tkImgPhoto.exc mkVFunc
Xlib.t : Xlib.h  Xlib.excwin mkVFunc
tix.t    : tix.h tix.exc mkVFunc
tixInt.t : tixInt.h tixInt.exc mkVFunc

config :: Xlib.t Lang.t tk.t tkInt.t tkImgPhoto.t tix.t tixInt.t 

config :: 

Methods.def : mkmethods $(C_FILES)
	$(PERL) mkmethods $@ $(C_FILES)

libpTk$(LIB_EXT) : Methods.def

';
}





