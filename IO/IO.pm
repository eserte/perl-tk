package Tk::IO;
require 5.002;
require Tk;
use Tk::Pretty;
require DynaLoader;
require Exporter;
require FileHandle;
use Carp;
@Tk::IO::ISA = qw(FileHandle DynaLoader Exporter);
@EXPORT_OK   = qw(System);

bootstrap Tk::IO;

my $seq = 0;

# Copied from POSIX
sub gensym 
{
 my $pkg = @_ ? ref($_[0]) || $_[0] : "";
 local *{$pkg . "::GLOB" . ++$seq};
 \delete ${$pkg . "::"}{'GLOB' . $seq};
}

sub new
{
 my ($package,%args) = @_;
 my $fh  = bless $package->gensym,$package;
 %{*$fh} = ();
 @{*$fh} = ();
 ${*$fh} = "";
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
       ${*$fh}{-linecommand}->Call(substr(${*$fh},0,++$eol));
       substr(${*$fh},0,$eol) = "";
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
 &Tk::Pretty::PrintArgs;
 my $fh = shift;
 my $code;
 my $ch = delete ${*$fh}{-childcommand};
 ${*$fh}{-childcommand} = Tk::Callbacksub->new(sub { $code = shift });
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

sub DESTROY
{  
 my $fh = shift;
 $fh->close;
}

1;
