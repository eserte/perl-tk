=head1 NAME

FindBin - Locate directory of original perl script

=head1 SYNOPSIS

 use FindBin;
 BEGIN { unshift(@INC,"$FindBin::Dir/../lib") }


=head1 DESCRIPTION


=head1 AUTHOR

Nick Ing-Simmons <nik@tiuk.ti.com>

=head1 COPYRIGHT

Copyright (c) 1995 Graham Barr. All rights reserved. This program is free 
software; you can redistribute it and/or modify it under the same terms 
as Perl itself.

=head1 REVISION HISTORY

=cut

package FindBin;
use Carp;

$Version = 1.0;		# Last edited 25th Jan 1995 by Graham Barr

require 5.000;

$SCRIPT = undef;
$BIN    = undef;

sub import {
 my($package) = @_;

 $SCRIPT = $0;
 unless (-x $SCRIPT)
  {
   my $dir;
   foreach $dir (split(/:/,$ENV{PATH}))
    {
     if (-x "$dir/$0")
      {
       $SCRIPT = "$dir/$0";
       last;
      }
    }
  }
 croak("Cannot find executable $SCRIPT") unless (-x $SCRIPT);

 $SCRIPT =~ s,^\./,,g;
 unless ($SCRIPT =~ m,^/,)
  {
   my $dir = `pwd`;
   chomp($dir);
   $SCRIPT = "$dir/$SCRIPT";
  }
 ($Dir,$Script) = $SCRIPT =~ m,^(.*)/([^/]+)$,;

 $RealScript = $SCRIPT;

 while(1)
  {
   my $linktext = readlink($SCRIPT);

   ($RealDir,$RealScript) = $SCRIPT =~ m,^(.*)/([^/]+)$,;
   last unless defined $linktext;

   $SCRIPT = ($linktext =~ m#^/#)
               ? $linktext
               : $RealDir . "/" . $linktext;
  }

}


1; # Keep require happy

