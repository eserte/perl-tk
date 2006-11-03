# Copyright (c) 1995-2003 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::MMtry;
use Config;
require Exporter;

use vars qw($VERSION @EXPORT);
$VERSION = sprintf '4.%03d', q$Revision: #9 $ =~ /\D(\d+)\s*$/;

use base  qw(Exporter);
@EXPORT = qw(try_compile try_run);
use strict;
use File::Basename;
use File::Spec;

my $stderr_too = ($^O eq 'MSWin32') ? '' : '2>&1';

sub try_compile
{
 my ($file,$inc,$lib,$def)  = @_;
 $inc = [] unless $inc;
 $lib = [] unless $lib;
 $def = [] unless $def;
 my $out   = basename($file,'.c').$Config{'exe_ext'};
 warn "Test Compiling $file\n";
 my $msgs  = `$Config{'cc'} -o $out $Config{'ccflags'} @$inc $file @$lib @$def $stderr_too`;
 my $ok = ($? == 0);
# warn $msgs if $msgs;
 unlink($out) if (-f $out);
 return $ok;
}

sub try_run
{
 my ($file,$inc,$lib,$def)  = @_;
 $inc = [] unless $inc;
 $lib = [] unless $lib;
 $def = [] unless $def;
 my $out   = basename($file,'.c').$Config{'exe_ext'};
 warn "Test Compile/Run $file\n";
 my $msgs  = `$Config{'cc'} -o $out $Config{'ccflags'} @$inc $file @$lib @$def $stderr_too`;
 my $ok = ($? == 0);
# warn "$Config{'cc'} -o $out $Config{'ccflags'} @$inc $file @$lib @$def:\n$msgs" if $msgs;
 if ($ok)
  {
   my $path = File::Spec->rel2abs($out);
   $msgs = `$path $stderr_too`;
   $ok = ($? == 0);
#  warn "$path:$msgs" if $msgs;
  }
 unlink($out) if (-f $out);
 return $ok;
}

1;
