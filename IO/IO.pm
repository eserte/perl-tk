package Tk::IO;
use strict;
use vars qw($VERSION @ISA);
$VERSION = '3.019'; # $Id: //depot/Tk8/IO/IO.pm#19$

require 5.002;
require Tk;

require DynaLoader;
require Exporter;
require IO::Handle;
use Carp;
use base  qw(DynaLoader IO::Handle Exporter);

bootstrap Tk::IO $Tk::VERSION;

sub new
{
 my ($package,%args) = @_;
 # Do whatever IO::Handle does
 my $fh  = $package->SUPER::new;
 %{*$fh} = ();  # The hash is used for configure options
 ${*$fh} = "";  # The scalar is used as the 'readable' buffer
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
 croak "No child" unless (defined $pid);
 kill($sig,-$pid);
}

sub kill
{
 my ($fh,$sig) = @_;
 my $pid = $fh->pid;
 croak "No child" unless (defined $pid);
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
       substr(${*$fh},0,$eol) = "";
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
 my $pid = open($fh,"-|");
 if ($pid)
  {
   ${*$fh} = "" unless (defined ${*$fh});
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
   exec(@_) || die "Cannot exec ",join(' ',@_),":$!";
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

sub PrintArgs
{
 my $func = (caller(1))[3];
 print "$func(",join(',',@_),")\n";
}

sub TIEHANDLE
{
 my ($class,$src) = @_;
 my $fh = new IO::Handle;
 *{$fh} = *{*$src}{IO};
 ${*$fh}{Handlers} = {};
 ${*$fh}{imode} = 0;
 return bless $fh,$class;
}

sub DESTROY
{
 my $obj = shift;
 $obj->CLOSE;
}

sub PRINT
{
 my $h = shift;
 return print $h @_;
}

sub PRINTF
{       
 &PrintArgs;
 my $h = shift;
 return printf $h @_;
}

sub WRITE
{              
 return syswrite($_[0],$_[1],$_[2]);
}

sub READLINE
{       
 my $h = shift;
 return <$h>;
}

sub READ
{   
 return sysread($_[0],$_[1],$_[2],$_[3]);
}

sub GETC
{
 return getc($_[0]);
}

sub CLOSE
{
 my $h = shift;  
 my $fd  = fileno($h);
 foreach my $mode (keys %{${*$h}{'Handlers'}})
  {
   $h->deleteHandler($mode);
  }
 DeleteFileHandler($fd) if (defined $fd);
 return $h->close; 
}

sub imode
{
 my $mode = shift;
 my $imode = ${{'readable' => READABLE(), 'writable' => WRITABLE()}}{$mode};
 croak("Invalid handler type '$mode'") unless (defined $imode);
 return $imode;
}

sub IOready
{
 my ($h,$rmode) = @_;
 foreach my $mode (keys %{${*$h}{'Handlers'}})
  {
   my $imode = imode($mode);
   if ($rmode & $imode)
    {
     ${*$h}{'Handlers'}{$mode}->Call;
    }
  }
}

sub addHandler
{
 my ($h,$mode,$cb) = @_;
 my $fd = fileno($h);                                             
 croak("Cannot add fileevent to unopened handle") unless defined $fd;
 $cb = Tk::Callback->new($cb);
 my $imode = imode($mode);
 ${*$h}{'Handlers'}{$mode} = $cb;
 unless (${*$h}{'imode'} & $imode)
  {
   DeleteFileHandler($fd);
   CreateFileHandler($fd, ${*$h}{'imode'} |= $imode, $h);
  }
}

sub deleteHandler
{
 my ($h,$mode) = @_;
 my $imode = imode($mode);
 my $fd  = fileno($h);
 if (${*$h}{'imode'} & $imode)
  {
   ${*$h}{'imode'} &= ~$imode;
   if (defined $fd)
    {
     DeleteFileHandler($fd);                                  
     CreateFileHandler($fd, ${*$h}{'imode'}, $h) if (${*$h}{'imode'});
    }
  }
 delete ${*$h}{'Handlers'}{$mode};
}

sub fileevent
{
 my ($widget,$file,$mode,$cb) = @_;
 croak "Unknown mode '$mode'" unless $mode =~ /^(readable|writable)$/;
 unless (ref $file)
  {
   no strict 'refs';
   $file = Symbol::qualify($file,(caller)[0]);
   $file = \*{$file};
  }
 my $obj = tie *$file,'Tk::IO', $file;
 $obj->deleteHandler($mode);
 $obj->addHandler($mode,$cb) if ($cb);
}

1;
__END__

