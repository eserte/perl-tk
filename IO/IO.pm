package Tk::IO;
use strict;
use vars qw($VERSION);
$VERSION = '3.031'; # $Id: //depot/Tk8/IO/IO.pm#32$

require 5.002;
require Tk;

require DynaLoader;
require Exporter;
require IO::Handle;
use Carp;
use base  qw(DynaLoader IO::Handle Exporter);

bootstrap Tk::IO $Tk::VERSION;

my %fh2obj;
my %obj2fh;

sub new
{
 my ($package,%args) = @_;
 # Do whatever IO::Handle does
 my $fh  = $package->SUPER::new;
 %{*$fh} = ();  # The hash is used for configure options
 ${*$fh} = '';  # The scalar is used as the 'readable' buffer
 @{*$fh} = ();  # The array
 $fh->configure(%args);
 return $fh;
}

sub pending
{
 my $fh = shift;
 return ${*$fh};
}

sub cget
{
 my ($fh,$key) = @_;
 return ${*$fh}{$key};
}

sub configure
{
 my ($fh,%args) = @_;
 my $key;
 foreach $key (keys %args)
  {
   my $val = $args{$key};
   $val = Tk::Callback->new($val) if ($key =~ /command$/);
   ${*$fh}{$key} = $val;
  }
}

sub killpg
{
 my ($fh,$sig) = @_;
 my $pid = $fh->pid;
 croak 'No child' unless (defined $pid);
 kill($sig,-$pid);
}

sub kill
{
 my ($fh,$sig) = @_;
 my $pid = $fh->pid;
 croak 'No child' unless (defined $pid);
 kill($sig,$pid) || croak "Cannot kill($sig,$pid):$!";
}

sub readable
{
 my $fh     = shift;
 my $count  = sysread($fh,${*$fh},1,length(${*$fh}));
 if ($count < 0)
  {
   if (exists ${*$fh}{-errorcommand})
    {
     ${*$fh}{-errorcommand}->Call($!);
    }
   else
    {
     warn "Cannot read $fh:$!";
     $fh->close;
    }
  }
 elsif ($count)
  {
   if (exists ${*$fh}{-linecommand})
    {
     my $eol = index(${*$fh},"\n");
     if ($eol >= 0)
      {
       my $line = substr(${*$fh},0,++$eol);
       substr(${*$fh},0,$eol) = '';
       ${*$fh}{-linecommand}->Call($line);
      }
    }
  }
 else
  {
   $fh->close;
  }
}

sub pid
{
 my $fh = shift;
 return ${*$fh}{-pid};
}

sub command
{
 my $fh  = shift;
 my $cmd = ${*$fh}{'-exec'};
 return (wantarray) ? @$cmd : $cmd;
}

sub exec
{
 my $fh  = shift;
 my $pid = open($fh,'-|');
 if ($pid)
  {
   ${*$fh} = '' unless (defined ${*$fh});
   ${*$fh}{'-exec'} = [@_];
   ${*$fh}{'-pid'}  = $pid;
   if (exists ${*$fh}{-linecommand})
    {
     my $w = ${*$fh}{-widget};
     $w = 'Tk' unless (defined $w);
     $w->fileevent($fh,'readable',[$fh,'readable']);
     ${*$fh}{_readable} = $w;
    }
   else
    {
     croak Tk::Pretty::Pretty(\%{*$fh});
    }
   return $pid;
  }
 else
  {
   # make STDERR same as STDOUT here
   setpgrp;
   exec(@_) || die 'Cannot exec ',join(' ',@_),":$!";
  }
}

sub wait
{
 my $fh = shift;
 my $code;
 my $ch = delete ${*$fh}{-childcommand};
 ${*$fh}{-childcommand} = Tk::Callback->new(sub { $code = shift });
 Tk->DoOneEvent until (defined $code);
 if (defined $ch)
  {
   ${*$fh}{-childcommand} = $ch;
   $ch->Call($code,$fh)
  }
 return $code;
}

sub close
{
 my $fh = shift;
 my $code;
 if (defined fileno($fh))
  {
   my $w = delete ${*$fh}{_readable};
   $w->fileevent($fh,'readable','') if (defined $w);
   $code = close($fh);
   if (exists ${*$fh}{-childcommand})
    {
     ${*$fh}{-childcommand}->Call($?,$fh);
    }
  }
 return $code;
}

{package Tk::Event::IO;

sub PrintArgs
{
 my $func = (caller(1))[3];
 print "$func(",join(',',@_),")\n";
}

sub PRINT
{
 my $obj = shift;
 unless ($obj->handler(WRITABLE))
  {
   Tk::DoOneEvent(0) until $obj->writable;
  }
 my $h = $obj->handle;
 return print $h @_;
}   

sub PRINTF
{
 my $obj = shift;
 unless ($obj->handler(WRITABLE))
  {
   Tk::DoOneEvent(0) until $obj->writable;
  }
 my $h = $obj->handle;
 return printf $h @_;
}

sub WRITE
{
 my $obj = $_[0];
 unless ($obj->handler(WRITABLE))
  {
   Tk::DoOneEvent(0) until $obj->writable;
  }
 return syswrite($obj->handle,$_[1],$_[2]);
}
            
my $depth = 0;
sub READLINE
{         
 my $obj = shift;
 my $h = $obj->handle;
 unless ($obj->handler(READABLE))
  {
   Tk::DoOneEvent(0) until $obj->readable;
  }
 my $w = <$h>;
 return $w;
}

sub READ
{
 my $obj = $_[0];
 unless ($obj->handler(READABLE))
  {
   Tk::DoOneEvent(0) until $obj->readable;
  }
 my $h = $obj->handle;
 return read($h,$_[1],$_[2],defined $_[3] ? $_[3] : 0);
}

sub GETC
{
 my $obj = $_[0];
 unless ($obj->handler(READABLE))
  {
   Tk::DoOneEvent(0) until $obj->readable;
  }
 my $h = $obj->handle;
 return getc($h);
}

sub CLOSE
{
 my $obj = shift;
 $obj->watch(0);
 my $h = $obj->handle;
 return close($h);
}   

}

sub imode
{
 my $mode = shift;
 my $imode = ${{'readable' => Tk::Event::IO::READABLE(), 
                'writable' => Tk::Event::IO::WRITABLE()}}{$mode};
 croak("Invalid handler type '$mode'") unless (defined $imode);
 return $imode;
}

sub fileevent
{
 my ($widget,$file,$mode,$cb) = @_;
 my $imode = imode($mode);
 unless (ref $file)
  {
   no strict 'refs';
   $file = Symbol::qualify($file,(caller)[0]);
   $file = \*{$file};
  }
 my $obj = tied(*$file);
 $obj = tie *$file,'Tk::Event::IO', $file unless $obj && $obj->isa('Tk::Event::IO');
 if (@_ == 3)
  {
   return $obj->handler($imode);
  }
 else
  {
   $obj->handler($imode,$cb);
  }
}

1;
__END__


