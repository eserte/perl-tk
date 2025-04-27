# Copyright (c) 1995-2003 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::MMtry;
use Config;
require Exporter;

use vars qw($VERSION @EXPORT $VERBOSE);
#$VERSION = sprintf '4.%03d', q$Revision: #9 $ =~ /\D(\d+)\s*$/;
$VERSION = '4.011';

use base  qw(Exporter);
@EXPORT = qw(try_compile try_run);
use warnings;
use strict;
use File::Basename;
use File::Spec;

my $CONSUME_STDERR  = ($^O eq 'MSWin32') ? '' : '2>&1';
my $SUPPRESS_STDERR = ($^O eq 'MSWin32') ? '' : '2>/dev/null';

sub try_compile
{
 return _do_try(0, @_);
}

sub try_run
{
 return _do_try(1, @_);
}

sub _do_try
{
 my ($do_run,$file,$inc,$lib,$def)  = @_;
 $inc ||= [];
 $lib ||= [];
 $def ||= [];
 my $stderr_too = $VERBOSE ? $CONSUME_STDERR : $SUPPRESS_STDERR;
 my $out   = basename($file,'.c').$Config{'exe_ext'};
 warn $do_run ? "Test Compile/Run $file\n" : "Test Compiling $file\n";
 my $cmdline = "$Config{'cc'} -o $out $Config{'ccflags'} @$inc $file $Config{ldflags} @$lib @$def";
 my $msgs  = `$cmdline $stderr_too`;
 my $ok = ($? == 0);
 warn "$cmdline\n$msgs" if $VERBOSE;
 if ($do_run and $ok)
  {
   my $path = File::Spec->rel2abs($out);
   $msgs = `$path $stderr_too`;
   $ok = ($? == 0);
   warn "$path\n$msgs" if $VERBOSE;
  }
 unlink($out) if (-f $out);
 return $ok;
}

1;
