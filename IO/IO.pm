package Tk::IO;
use strict;
use vars qw($VERSION @ISA);
$VERSION = '3.013'; # $Id: //depot/Tk8/IO/IO.pm#13$

require 5.002;
require Tk;

require DynaLoader;
require Exporter;
require IO::Handle;
use Carp;
@ISA = qw(DynaLoader IO::Handle Exporter);

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

sub kill
{
 my ($fh,$sig) = @_;
 my $pid = $fh->pid;
 croak "No child" unless (defined $pid);
 kill($sig,$pid) || croak "Cannot kill($sig,$pid):$!";
}

sub killpg
{
 my ($fh,$sig) = @_;
 my $pid = $fh->pid;
 croak "No child" unless (defined $pid);
 kill($sig,-$pid);
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
 if (defined fileno($fh))
  {
   my $w = delete ${*$fh}{_readable};
   $w->fileevent($fh,'readable','') if (defined $w);
   close($fh);
   if (exists ${*$fh}{-childcommand})
    {
     ${*$fh}{-childcommand}->Call($?,$fh);
    }
  }
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
 &PrintArgs;
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
 &PrintArgs;
}

sub READLINE
{
 my $h = shift;
 return <$h>;
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
 close($h);
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

=head1 NAME

Tk::IO - high level interface to Tk's 'fileevent' mechanism

=for category Binding Events and Callbacks

=head1 SYNOPSIS

  my $fh = Tk::IO->new(-linecommand => callback, -childcommand => callback);
  $fh->exec("command")
  $fh->wait
  $fh->kill

=head1 WARNING

INTERFACES TO THIS MODULE MAY CHANGE AS PERL'S IO EVOLVES
AND WITH PORT OF TK4.1

=head1 DESCRIPTION

Tk::IO is now layered on perl's IO::Handle class. Interfaces 
have changed, and are still evolving. 

In theory C methods which enable non-blocking IO as in earlier Tk-b*
release(s) are still there. I have not changed them to use perl's 
additional Configure information, or tested them much.

Assumption is that B<exec> is 
used to fork a child process and a callback is called each time a 
complete line arrives up the implied pipe.

"line" should probably be defined in terms of perl's input record
separator but is not yet.

The -childcommand callback is called when end-of-file occurs.

$fh->B<wait> can be used to wait for child process while processing
other Tk events.

$fh->B<kill> can be used to send signal to child process.

=head1 BUGS

Still not finished.
Idea is to use "exec" to emulate "system" in a non-blocking manner.

