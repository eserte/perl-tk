package Tk::MMutil;
use ExtUtils::MakeMaker;
use Cwd;
use Tk::Config;
@MYEXPORT = qw(perldepend const_config constants c_o xs_o makefile);

sub relpath
{
 my ($path) = @_;
 if (defined $dir)
  {
   if ($path =~ m#^$dir\b(.*)$#)
    {
     my $base  = $1;
     my $here  = getcwd;
     if ($here =~ m#^$dir\b(.*)#)
      {
       my $depth = reverse($1);
       if ($depth)
        {
         $depth =~ s,[^/]+,..,g;
        }
       else
        {
         $depth = '.' ;
        }
       $depth =~ s,/+$,,;
       $base =~ s,^/+,,;
       $depth .= "/$base" if ($base);
       if (-e $depth)
        {
         # print "$path is $depth from $here\n";
         return $depth;
        }
      }
    }
  }
 else
  {
   warn "No directory defined";
  }
 return $path;
}

use strict;


sub upgrade_pic
{
 my $flags = "";
 die "upgrade_pic is obsolete";
 return $flags;
}

sub perldepend
{
 my $self = shift;
 my $str = $self->MM::perldepend;
 my $name;
 my @files;
 foreach $name ($self->lsdir("."))
  {
   $str .= `cat $name` if ($name =~ /\.d$/);
  }
 return $str;
}

sub const_config
{
 my $self = shift;
 my $flags = $self->{'CCCDLFLAGS'};
 $flags =~ s/(-[fK]?\s*)pic\b/${1}PIC/; 
 $self->{'CCCDLFLAGS'} = $flags;
 return $self->MM::const_config;
}

sub constants
{
 my $self = shift;
 local $_ = $self->MM::constants;
 s/(\.SUFFIXES)/$1:\n$1/;
 $_ .= "\nGCCOPT = $Tk::Config::gccopt\n";
 $_;
}

sub c_o
{
 my $self = shift;
 local $_ = $self->MM::c_o;
 s/\$\(DEFINE\)/\$(DEFINE) \$(GCCOPT)/;
 $_;
}

sub xs_o
{
 my $self = shift;
 local $_ = $self->MM::xs_o;
 s/\$\(DEFINE\)/\$(DEFINE) \$(GCCOPT)/;
 $_;
}

sub findINC
{
 my $file = shift;
 my $dir;
 foreach $dir (@INC)
  {
   my $try = "$dir/$file";
   return $try if (-f $try);
  }
 die "Cannot find $file in \@INC\n";
}

sub makefile
{
 my $self = shift;
 my $str  = $self->MM::makefile;
 my $mm = findINC('Tk/MMutil.pm');
 my $cf = findINC('Tk/Config.pm');
 $str =~ s/(\$\(CONFIGDEP\))/$1 $cf $mm/;
 return $str;
}

sub installed_tk
{
 my $tk; 
 my $dir;
 foreach $dir (@INC)
  {
   if (-f "$dir/tkGlue.h")
    {
     $tk = $dir;
     last;
    }
   my $try = "$dir/Tk";
   if (-f "$try/tkGlue.h")
    {
     $tk = $try;
     last;
    }
  }
 die "Cannot find perl/Tk include files\n" unless (defined $tk);
 $tk =~ s,^(\./)+,,;
 return relpath($tk);
}

sub findpTk
{
 my $ptk;
 my $dir;
 foreach $dir (@INC)
  {
   my $try = "$dir/pTk";
   if (-d $try && (-f "$try/tkWindow.c" || -f "$try/libpTk\$(LIB_EXT)"))
    {
     $ptk = $try;
     last;
    }
  }
 die "Cannot locate pTk\n" unless (defined $ptk); 
 return relpath($ptk);
}

sub TkExtMakefile
{
 my (%att) = @_;
 unless (exists $att{'NAME'})
  {
   my $dir = getcwd;
   my ($pack) = $dir =~ m#/([^/]+)$#;
   if (defined $pack)
    {
     $att{NAME} = 'Tk::'.$pack;
    }
   else
    {
     warn "No Name and cannot deduce from '$dir'";
    }
  }
 # 'INST_LIB' => '../blib',
 # 'INST_ARCHLIB' => '../blib',
 my @opt = ('VERSION'     => $Tk::Config::VERSION);
 push(@opt,'clean' => {} ) unless (exists $att{'clean'});
 $att{'clean'}->{FILES} = '' unless (exists $att{'clean'}->{FILES});
 $att{'clean'}->{FILES} .= " *% *.bak";
 unless (exists($att{'linkext'}) && $att{linkext}{LINKTYPE} eq '')
  {
   my @tm = (findINC('Tk/typemap'));
   unshift(@tm,@{$att{'TYPEMAPS'}}) if (exists $att{'TYPEMAPS'});
   $att{'TYPEMAPS'} = \@tm;
   my $i = delete ($att{'INC'});
   $i = (defined $i) ? "$i $inc" : $inc;
   if (delete $att{'dynamic_ptk'})
    {
     my $ptk = findpTk();
     push(@opt, 
          'dynamic_lib' => { OTHERLDFLAGS => "$ptk/libpTk\$(LIB_EXT)",
                             INST_DYNAMIC_DEP => "$ptk/libpTk\$(LIB_EXT)"
                            }
         ); 
    }
   if (delete $att{'ptk_include'})
    {
     my $ptk = findpTk();
     $i = "-I$ptk $i" unless ($ptk eq '.');
    }
   else
    {
     my $tk = installed_tk();
     $i = "-I$tk $i" unless ($tk eq '.');
    }
   push(@opt,'DEFINE' => $define, 'INC' => $i);
  }
 WriteMakefile(@opt, %att);
}

sub import
{
 no strict 'refs';
 my $class = shift;
 my @list = (@_) ? @_ : @{"${class}::MYEXPORT"};
 my $name;
 foreach $name (@list)
  {
   *{"MY::$name"} = \&{"$name"};
  }
}


1;
