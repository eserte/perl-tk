package Tk::ProgressBar;

use vars qw($VERSION);
$VERSION = '3.008'; # $Id: //depot/Tk8/Tk/ProgressBar.pm#8 $

use Tk;
use Tk::Canvas;
use Carp;
use strict;

use base qw(Tk::Derived Tk::Canvas);

Construct Tk::Widget 'ProgressBar';

sub ClassInit {
    my ($class,$mw) = @_;

    $class->SUPER::ClassInit($mw);

    $mw->bind($class,'<Configure>', ['_layoutRequest',1]);
    $mw->bind($class,'<Destroy>', 'Destroyed');
}


sub Populate {
    my($c,$args) = @_;

    $c->ConfigSpecs(
	-width    => [PASSIVE => undef, undef, 0],
	'-length' => [PASSIVE => undef, undef, 0],
	-from	  => [PASSIVE => undef, undef, 0],
	-to	  => [PASSIVE => undef, undef, 100],
	-blocks   => [PASSIVE => undef, undef, 10],
	-padx     => [PASSIVE => 'padX', 'Pad', 0],
	-pady     => [PASSIVE => 'padY', 'Pad', 0],
	-gap      => [PASSIVE => undef, undef, 1],
	-colors   => [PASSIVE => undef, undef, undef],
	-relief	  => [SELF => 'relief', 'Relief', 'sunken'],
	-value    => [METHOD  => undef, undef, undef],
	-variable => [METHOD  => undef, undef, undef],
	-anchor   => [METHOD  => 'anchor', 'Anchor', 'w'],
	-resolution
		  => [PASSIVE => undef, undef, 1.0],
	-highlightthickness
		  => [SELF => 'highlightThickness','HighlightThickness',0],
	-troughcolor
		  => [PASSIVE => 'troughColor', 'Background', 'grey55'],
    );
    _layoutRequest($c,1);
}

sub anchor {
    my $c = shift;
    my $var = \$c->{Configure}{'-anchor'};
    my $old = $$var;

    if(@_) {
	my $new = shift;
	croak "bad anchor position \"$new\": must be n, s, w or e"
		unless $new =~ /^[news]$/;
	$$var = $new;
    }

    $old;
}

sub _layoutRequest {
    my $c = shift;
    my $why = shift;
    $c->DoWhenIdle(['_arrange',$c]) unless $c->{'layout_pending'};
    $c->{'layout_pending'} |= $why;
}

sub _arrange {
    my $c = shift;
    my $why = $c->{'layout_pending'};

    $c->{'layout_pending'} = 0;

    my $w = $c->Width;
    my $h = $c->Height;
    my $bw = $c->cget('-borderwidth') + $c->cget('-highlightthickness');
    my $x = abs(int($c->{Configure}{'-padx'})) + $bw;
    my $y = abs(int($c->{Configure}{'-pady'})) + $bw;
    my $value = $c->value;
    my $from = $c->{Configure}{'-from'}; 
    my $to   = $c->{Configure}{'-to'};
    my $horz = $c->{Configure}{'-anchor'} =~ /[ew]/i ? 1 : 0;
    my $dir  = $c->{Configure}{'-anchor'} =~ /[ne]/i ? -1 : 1;

    my($minv,$maxv) = $from < $to ? ($from,$to) : ($to,$from);

    if($w == 1 && $h == 1) {
	my $bw = $c->cget('-borderwidth');
	my $defw = 10 + $y*2 + $bw *2;
	my $defl = ($maxv - $minv) + $x*2 + $bw*2;

	$h = $c->pixels($c->{Configure}{'-length'}) || $defl;
	$w = $c->pixels($c->{Configure}{'-width'})  || $defw;

	($w,$h) = ($h,$w) if $horz;
	$c->GeometryRequest($w,$h);
	$c->parent->update;
	$c->update;

	$w = $c->Width;
	$h = $c->Height;
    }

    $w -= $x*2;
    $h -= $y*2;

    my $length = $horz ? $w : $h;
    my $width  = $horz ? $h : $w;
   
    my $blocks = int($c->{Configure}{'-blocks'});
    my $gap    = int($c->{Configure}{'-gap'});

    $blocks = 1 if $blocks < 1;

    my $gwidth = $gap * ( $blocks - 1);
    my $bwidth = ($length - $gwidth) / $blocks;

    if($bwidth < 3 || $blocks <= 1 || $gap <= 0) {
	$blocks = 1;
	$bwidth = $length;
	$gap = 0;
    }

    if($why & 1) {
	my $colors = $c->{Configure}{'-colors'} || [];
	my $bdir = $from < $to ? $dir : 0 - $dir;

	$c->delete($c->find('all'));

	$c->createRectangle(0,0,$w+$x*2,$h+$y*2,
		-fill =>  $c->{Configure}{'-troughcolor'},
		-width => 0,
		-outline => undef);

	$c->{'cover'} =	$c->createRectangle($x,$y,$w,$h,
		-fill =>  $c->{Configure}{'-troughcolor'},
		-width => 0,
		-outline => undef);

	my($x0,$y0,$x1,$y1);

	if($horz) {
	    if($bdir > 0) {
		($x0,$y0) = ($x - $gap,$y);
	    }
	    else {
		($x0,$y0) = ($length + $x + $gap,$y);
	    }
	    ($x1,$y1) = ($x0,$y0 + $width);
	}
	else {
	    if($bdir > 0) {
		($x0,$y0) = ($x,$y - $gap);
	    }
	    else {
		($x0,$y0) = ($x,$length + $y + $gap);
	    }
	    ($x1,$y1) = ($x0 + $width,$y0);
	}

	my $blks  = $blocks;
	my $dval  = ($maxv - $minv) / $blocks;
	my $color = $c->cget('-foreground');
	my $pos   = 0;
	my $val   = $minv;

	while($val < $maxv) {
	    my($bw,$nval);

	    while(($pos < @$colors) && $colors->[$pos] <= $val) {
		$color = $colors->[$pos+1];
		$pos += 2;
	    }

	    if($blocks == 1) {
		$nval = defined($colors->[$pos])
			? $colors->[$pos] : $maxv;
		$bw = (($nval - $val) / ($maxv - $minv)) * $length;
	    }
	    else {
		$bw = $bwidth;
		$nval = $val + $dval if($blocks > 1);
	    }

	    if($horz) {
		if($bdir > 0) {
		    $x0 = $x1 + $gap;
		    $x1 = $x0 + $bw;
		}
		else {
		    $x1 = $x0 - $gap;
		    $x0 = $x1 - $bw;
		}
	    }
	    else {
		if($bdir > 0) {
		    $y0 = $y1 + $gap;
		    $y1 = $y0 + $bw;
		}
		else {
		    $y1 = $y0 - $gap;
		    $y0 = $y1 - $bw;
		}
	    }

	    $c->createRectangle($x0,$y0,$x1,$y1,
		-fill => $color,
		-width => 0,
		-outline => undef
	    );
	    $val = $nval;
	}
    }

    my $cover = $c->{'cover'};
    my $ddir = $from > $to ? 1 : -1;

    if(($value <=> $to) == (0-$ddir)) {
	$c->lower($cover);
    }
    elsif(($value <=> $from) == $ddir) {
	$c->raise($cover);
	my $x1 = $horz ? $x + $length : $x + $width;
	my $y1 = $horz ? $y + $width : $y + $length;
	$c->coords($cover,$x,$y,$x1,$y1);
    }
    else {
	my $step;
	$value = int($value / $step) * $step
	    if(defined($step = $c->{Configure}{'-resolution'}) && $step > 0);

	$maxv = $minv+1
	    if $minv == $maxv;

	my $range = $maxv - $minv;
	my $bval = $range / $blocks;
	my $offset = abs($value - $from);
	my $ioff = int($offset / $bval);
	my $start = $ioff * ($bwidth + $gap);
	$start += ($offset - ($ioff * $bval)) / $bval * $bwidth;

	my($x0,$x1,$y0,$y1);
	
	if($horz) {
	    $y0 = $y;
	    $y1 = $y + $h;
	    if($dir > 0) {
		$x0 = $x + $start;
		$x1 = $x + $w;
	    }
	    else {
		$x0 = $x;
		$x1 = $w + $x - $start;
	    }
	}
	else {
	    $x0 = $x;
	    $x1 = $x + $w;
	    if($dir > 0) {
		$y0 = $y + $start;
		$y1 = $y + $h;
	    }
	    else {
		$y0 = $y;
		$y1 = $h + $y - $start;
	    }
	}

	
	$c->raise($cover);
	$c->coords($cover,$x0,$y0,$x1,$y1);
    }
}

sub value {
    my $c = shift;
    my $val = defined($c->{Configure}{'-variable'})
		? $c->{Configure}{'-variable'}
		: \$c->{Configure}{'-value'};
    my $old = defined($$val) ? $$val : $c->{Configure}{'-from'};

    if(@_) {
	my $value = shift;
	$$val = defined($value) ? $value : $c->{Configure}{'-from'};
	_layoutRequest($c,2);
    }

    $old;
}

sub variable {
    my $c = shift;
    my $val = \$c->{Configure}{'-variable'};
    my $old = $$val;
    if(@_) {
	my $value = shift;
        if (ref $old)
         {
          $c->{Configure}{'-value'} = $$old;
          untie $$old if tied($$old);
         }
        tie $$value,'Tk::Configure',$c,'-value';
	$$val = $value;   
	_layoutRequest($c,2);
    }
    $old;
}

sub Destroyed
{
 my $c = shift;
 my $var = delete $c->{Configure}{'-variable'};
 untie $$var if (defined($var) && ref($var))
}

1;
__END__

=head1 NAME

Tk::ProgressBar - A graphical progress bar

=for category Derived Widgets

=head1 SYNOPSIS

    use Tk::ProgressBar;
    
    $progress = $parent->ProgressBar(
	-width => 200,
	-height => 20,
	-from => 0,
	-to => 100,
	-blocks => 10,
	-colors => [0, 'green', 50, 'yellow' , 80, 'red'],
	-variable => \$percent_done
    );


=head1 DESCRIPTION

B<Tk::ProgressBar> provides a widget which will show a graphical representation
of a value, given maximum and minimum reference values.

=head1 STANDARD OPTIONS

B<-padx -pady -troughcolor -highlightthickness -borderwidth -relief>


=head1 WIDGET-SPECIFIC OPTIONS

=over 4

=item -width

Specifies the desired narrow dimension of the ProgressBar in screen units (i.e.
any of the forms acceptable to Tk_GetPixels). For vertical ProgressBars this is
the ProgressBars width; for horizontal bars this is the ProgressBars height. 


=item -length

Specifies the desired long dimension of the ProgressBar in screen units (i.e. any
of the forms acceptable to Tk_GetPixels). For vertical ProgressBars this is the
ProgressBars height; for horizontal scales it is the ProgressBars width. 

=item -colors

=item -blocks

=item -resolution

A real value specifying the resolution for the scale. If this value is greater
than zero then the scale's value will always be rounded to an even multiple of
this value, as will tick marks and the endpoints of the scale. If the value is
less than zero then no rounding occurs. Defaults to 1 (i.e., the value will be
integral). 

=item -anchor

=item -variable

Specifies the reference to a scalar variable to link to the ProgressBar.
Whenever the value of the variable changes, the ProgressBar will upate
to reflect this value. (See also the B<value> method below.)

=item -from

=item -to

=item -gap

=back

=head1 WIDGET METHODS

=over 4

=item I<$ProgressBar>->B<value>(?I<value>?)

If I<value> is omitted, returns the current value of the ProgressBar.  If
I<value> is given, the value of the ProgressBar is set. If I<$value> is
given but undefined the value of the option B<-from> is used.

=back


=head1 AUTHOR

Graham Barr E<lt>F<gbarr@pobox.com>E<gt>

=head1 COPYRIGHT

Copyright (c) 1997-1998 Graham Barr. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut


