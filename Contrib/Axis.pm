package Axis;

=head1 NAME 

Axis - Canvas with Axes

=head1 SYNOPSIS

  $mw = MainWindow->new;                                           
  $t = $mw->Axis(-xmax => 10, -ymax => 10);                        
  $t->create('line',$t->plx(2),$t->ply(3.1),$t->plx(4),$t->ply(4));

=head1 DESCRIPTION

This is an improved version of the axis widget. Changes with respect to the
previous version are :

=over 4

=item * 

the 'pack' has been moved out the widget. One has to do his own packing

=item * 

it is now possible to work in the coordinates of the axis. The following
piece of code draws a line between the points (2 , 3.1)  (4 , 4).

=back 

=head1 AUTHOR

 Kris Boulez		(Kris.Boulez@rug.ac.be)
 Biomolecular NMR unit	<http://bionmr1.rug.ac.be/~kris>
 University of Ghent, Belgium

=cut 

require 5.002;
require Tk::Canvas;
use Carp;

@ISA = qw(Tk::Derived Tk::Canvas);

Construct Tk::Widget 'Axis';


# Added since v 0.1
# -----------------
# - plx en ply allow you to work in axis coordinates
#       (eg. $t->create('line', $t->plx(.3), $t->ply(.4), $t->plx(3.2), 
#                          $t->ply(5.3)); ) 
# - pack is moved out.
#
# This is an Axis widget. It draws an XY axis on the screen and draws 
# tickmarks. This is the first public version (v 0.2), all comments, 
# crticism, ... are welcome (kris@bionmr1.rug.ac.be).
#
# I would like to thank the following people :
# - Ton Rullmann (rull@nmr.chem.ruu.nl) who started my quest for a way to
# draw 2D plot from within Perl
# - Stephen O. Lidie (lusol@Turkey.CC.Lehigh.edu) who provided me with a 
# 2D plot script. He also asked the question "why don't you write a new
# widget for it ?"
# - Nick Ing-Simmons (nik@tiuk.ti.com) without who there would be no ptk
# and whose advice was invaluable while trying to create this widget
#
# It is used as follows
#
#   require Axis;
#
#   $AxisRef = $mw->Axis(
# 		       -width => $width,
# 		       -height => $height,
# 		       -xmin   => $xmin,
# 		       -xmax   => $xmax,
# 		       -ymin   => $ymin,
# 		       -ymax   => $ymax,
# 		       -margin => $margin,
# 		       -tick   => $tick,
# 		       -tst    => $tst,
# 		      );
#
#    mw      - a window reference (usually from a MainWindow->new call).
#    height  - height of the window (Nick, what is the default for this ?)
#    width   - width  ......
#    xmin    - lowest x value we will display
#    xmax    - highest .....
#    ymin    - lowest y value .....
#    ymax    - highest .....
#    margin  - the number of pixels used as a margin around the plot
#    tick    - the length (in pixels) of the tickmarks
#    tst     - the step size for the tick marks
#    tst[x|y]- step size for tick marks on the x (or y) axis
#                (if not specified tst is used)
#   $AxisRef->pack;
#     (A Show method is supplied for compatibility with other widgets) 


sub Populate    #using Populate from Tk::Derived
{
  my ($w,$args) = @_;
  $w->SUPER::Populate($args);
  $w->ConfigSpecs(
		  '-xmin'   => ['PASSIVE',undef,undef,0],
		  '-xmax'   => ['PASSIVE',undef,undef,undef],
		  '-ymin'   => ['PASSIVE',undef,undef,0],
		  '-ymax'   => ['PASSIVE',undef,undef,undef],
		  '-margin' => ['PASSIVE',undef,undef,25],
		  '-tick'   => ['PASSIVE',undef,undef,10],
		  '-tst'    => ['PASSIVE',undef,undef,5],
		  '-tstx'   => ['PASSIVE',undef,undef,undef],
		  '-tsty'   => ['PASSIVE',undef,undef,undef],
		 ); # these options are new for the widget, the last value is 
                    # the default. 
} #end of Populate


sub ConfigChanged {
  my ($w,$args)= @_;;

  my $xmin = $w->cget(-xmin);   # how expensive is a ->cget ?
  my $xmax = $w->cget(-xmax);
  my $cx = $w->cget(-width);
  my $mar = $w->cget(-margin);
  my $ymin = $w->cget(-ymin);
  my $ymax = $w->cget(-ymax);
  my $cy = $w->cget(-height);
  my $tick = $w->cget(-tick);
  my $tst = $w->cget(-tst);
  my $tstx = $w->cget(-tstx);
  my $tsty = $w->cget(-tsty);

  if (!defined ($xmax) || !defined ($ymax)) { # at least xmax and ymax needed
    croak "Axis: `Show' method requires xmax and ymax";
  }
  if (!defined ($tstx)) {$tstx = $tst;}
  if (!defined ($tsty)) {$tsty = $tst;}

  my ($zx,$zy,$t); # zx (zy) is the value (in window coordinates) where 
                   # x (y) is 0 on the X (Y) axis
  if (abs($xmin+$xmax) > abs($xmin-$xmax)) { # both values pos/neg
    $zx=$mar;
  }
  else {
    $zx = $w->plx(0);
  }

  if (abs($ymin+$ymax) > abs($ymin-$ymax)) {
    $zy=$cy-$mar;
  }
  else {   # $cy - $mar is lowest point where we will draw
    $zy = $w->ply(0);
  }  
  
 # X-axis 
 # ------
  $w->create('line',
	     $mar, $zy, $cx-$mar, $zy);
  my (@t) = (); # @t contains the points where to draw tick marks
  if ($zx ==  0) {
    for ($t=$xmin; $t<=$xmax; $t+=$tstx) { push (@t,$t); }
  }
  else {
    for ($t=0; $t<=$xmax; $t+=$tstx) { push (@t,$t); }
    for ($t=-$tstx; $t>=$xmin; $t-=$tstx) { push(@t,$t);}
  }

  for $t (@t) {
    my $x = ($cx-2*$mar)*($t-$xmin)/abs($xmax-$xmin) + $mar;
    $w->create('line',
	       $x, $zy, $x, $zy+$tick);
    $w->create('text',
	       $x+5,$zy+20, text => $t, -anchor => 'sw');
  }

 # Y-axis
 # ------
  $w->create('line',
	     $zx, $mar, $zx, $cy-$mar);
  @t = ();
  if ($zy ==  $cy-$mar) {     # only pos/neg values
    for ($t=$ymin; $t<=$ymax; $t+=$tsty) { push (@t,$t); }
  }
  else {
    for ($t=$tsty; $t<=$ymax; $t+=$tsty) { push (@t,$t); }
    for ($t=-$tsty; $t>=$ymin; $t-=$tsty) { push(@t,$t);}
  }

  for $t (@t) {
    my $y = ($cy - $mar) - ($cy-2*$mar)*($t-$ymin)/abs($ymax-$ymin);
    $w->create('line',
	       $zx, $y, $zx-$tick, $y);
    $w->create('text',
	       $zx -15,$y+20, text => $t, -anchor => 'sw');
  }
} # end ConfigChanged

sub Show {   # all the drawing is allready done in ConfigChanged. Show is only
             # supplied for compatibility with other widgets.
} #end Show

sub plx {
  my ($w,$args) = @_;
  my $xmin = $w->cget(-xmin);   # how expensive is a ->cget ?
  my $xmax = $w->cget(-xmax);
  if (($args < $xmin)||($args>$xmax)) 
    {die "PLX: Out of limits\nXmin: $xmin\t\tValue: $args\nXmax: $xmax\n\n";}
  my $wi = $w->cget(-width);
  my $ma = $w->cget(-margin);
  return ((($wi-2*$ma)/abs($xmax-$xmin))*abs($args-$xmin) + $ma);
} #end plx

sub ply {
  my ($w,$args) = @_;
  my $ymin = $w->cget(-ymin);   # how expensive is a ->cget ?
  my $ymax = $w->cget(-ymax);
  if (($args < $ymin)||($args>$ymax)) 
    {die "PLY: Out of limits\nYmin: $ymin\t\tValue: $args\nYmax: $ymax\n\n";}
  my $he = $w->cget(-height);
  my $ma = $w->cget(-margin);
  return ($he - $ma -(($he-2*$ma)/abs($ymax-$ymin))*abs($args-$ymin));

} #end plx

1;

__END__

