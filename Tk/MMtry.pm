package Tk::MMtry;
use Config;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(try_compile try_run);
use strict;

sub try_compile
{
 my $file  = shift;
 my $msgs  = `$Config{'cc'} $Config{'ccflags'} $file 2>&1`;
 my $ok = ($? == 0);
 unlink('a.out') if (-f 'a.out');
 return $ok;
}

sub try_run
{
 my $file  = shift;
 my $msgs  = `$Config{'cc'}  $Config{'ccflags'} $file 2>&1`;
 my $ok = ($? == 0);
 if ($ok)
  {
   system('a.out');
   $ok = ($? == 0);
  }
 unlink('a.out') if (-f 'a.out');
 return $ok;
}

1;
