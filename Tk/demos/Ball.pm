# Ball.pm
#
# The Ball module
#
# Gurusamy Sarathy
# send comments to gsar@engin.umich.edu
#

package Ball;
require 5.000;

use Tk;
use English;

#@EXPORT = qw(Ball);

# Global to hold all balls created
@Balls = ();

sub new {
  my($class, $canv, $color, $size, $pos_ref, $vel_ref) = @ARG;
  my($ballobj);

  $color = 'blue' unless $color;
  $size  = 20.0 unless $size;
  $pos_ref = [12.0,12.0] unless $pos_ref;
  $vel_ref = [6.0, 9.0] unless $vel_ref;

  $ball = $canv->create('oval', ($pos_ref->[0] - ($size/2.0)), ($pos_ref->[1] - ($size/2.0)),
                                ($pos_ref->[0] + ($size/2.0)), ($pos_ref->[1] + ($size/2.0)),
                                -fill => $color);

  $ballobj = {'ball'   => $ball,
              'canvas' => $canv,
              'color'  => $color, 
              'size'   => $size,
              'pos'    => $pos_ref,
              'vel'    => $vel_ref};

#  $canv->bind($ball, '<B1-Motion>', eval 'sub {my($w) = shift; my($v) = $w->XEvent;
#                                               my($posx, $posy) = 
#                                                   $canv->coords($ball, $w->x, $w->y)}');
  $canv->bind($ball, '<Enter>', 
              eval 'sub {$canv->itemconfigure($ballobj->{\'ball\'}, &-fill => \'black\');}' );
  $canv->bind($ball, '<Leave>', 
              eval 'sub {$canv->itemconfigure($ballobj->{\'ball\'}, &-fill => $ballobj->{\'color\'});}' );
  push(@Balls, $ballobj);

  return bless $ballobj;
}

sub move {
  my ($ballobj, $speedratio) = @ARG;
  my ($ball, $canv, $minx, $miny, $maxx, $maxy, $ballx, $bally, $deltax, $deltay);

  $speedratio = 1.0 unless defined($speedratio);
  $ball = $ballobj->{'ball'};
  $canv = $ballobj->{'canvas'};
  $ballx = $ballobj->{'pos'}[0];
  $bally = $ballobj->{'pos'}[1];

  $minx = $ballobj->{'size'} / 2.0;
  $maxx = $ballobj->{'canvas'}->cget(-width) - $minx;

  $miny = $ballobj->{'size'} / 2.0;
  $maxy = $ballobj->{'canvas'}->cget(-height) - $miny;

  if ($ballx > $maxx || $ballx < $minx) {
        $ballobj->{'vel'}[0] = -1.0 * $ballobj->{'vel'}[0];
  }
  if ($bally > $maxy || $bally < $miny) {
        $ballobj->{'vel'}[1] = -1.0 * $ballobj->{'vel'}[1];
  }

  $deltax = $ballobj->{'vel'}[0] * $speedratio;
  $deltay = $ballobj->{'vel'}[1] * $speedratio;

  $canv->move($ball, $deltax, $deltay);
  $ballobj->{'pos'}[0] = $ballx + $deltax;
  $ballobj->{'pos'}[1] = $bally + $deltay;

  return $ballobj;
}

sub moveAll {
  my($class, $speedratio) = @ARG;
  my($ball);
  for $ball (@Balls) {
        $ball->move($speedratio);
        DoOneEvent(1);  # be kind and process Xevents if they arise
  }
}


1;
