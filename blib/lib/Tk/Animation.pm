package Tk::Animation;

use vars qw($VERSION);
$VERSION = '2.005'; # $Id: //depot/Tk/Tk/Animation.pm#5$

use Tk::Photo;
use Data::Dumper;
@ISA = qw(Tk::Photo);

Construct Tk::Widget 'Animation';

sub MainWindow
{
 return shift->{'_MainWIndow_'};
}

sub add_frame
{
 my $obj = shift;
 $obj->{'_frames_'} = [] unless exists $obj->{'_frames_'};
 push(@{$obj->{'_frames_'}},@_);
}

sub new
{
 my ($class,$widget,%args) = @_;
 my $obj = $class->SUPER::new($widget,%args);
 $obj->{'_MainWIndow_'} = $widget->MainWindow;
 if ($args{'-format'} eq 'gif')
  {
   my @images;
   local $@;
   while (1)
    {
     my $index = @images;
     $args{'-format'} = "gif -index $index";
     my $img;
     eval {local $SIG{'__DIE__'};  $img = $class->SUPER::new($widget,%args) };
     last if $@;
     push(@images,$img);
    }
   if (@images > 1)
    {
     $obj->add_frame(@images);
     $obj->{'_frame_index_'}  = 0;
    }
  }
 return $obj; 
}

sub set_image
{
 my ($obj,$index)  = @_;
 my $frames = $obj->{'_frames_'};
 return unless $frames && @$frames;
 $index = 0 unless $index < @$frames;
 $obj->copy($frames->[$index]);
 $obj->{'_frame_index_'} = $index;
}

sub next_image
{
 my ($obj)  = @_;
 my $frames = $obj->{'_frames_'};
 return unless $frames && @$frames;
 $obj->set_image((($obj->{'_frame_index_'} || 0)+1) % @$frames);
}

sub start_animation
{
 my ($obj,$period) = @_;
 my $frames = $obj->{'_frames_'};
 return unless $frames && @$frames;
 my $w = $obj->MainWindow;
 $obj->RepeatId($w->repeat($period,[$obj,'next_image']));
}

sub stop_animation
{
 my ($obj) = @_;
 $obj->CancelRepeat;
 $obj->set_image(0);
}

1;
__END__

=head1 NAME

Tk::Animation - Display sequence of Tk::Photo images

=head1 SYNOPSIS

  use Tk::Animation
  my $img = $widget->Animation('-format' => 'gif', -file => 'somefile.gif');
  
  $img->start_animation($period);
  $img->stop_animation;

  $img->add_frames(@images);

=head1 DESCRIPTION

In the simple case when C<Animation> is passed a GIF89 style GIF with 
multiple 'frames', it will build an internal array of C<Photo> images.

C<start_animation($period)> then initiates a C<repeat> with specified I<$period>
to sequence through these images.

C<stop_animation> cancels the C<repeat> and resets the image to the first
image in the sequence.

The C<add_frames> method adds images to the sequence. It is provided
to allow animations to be constructed from separate images.
All images must be C<Photo>s and should all be the same size.

=head1 BUGS

The 'period' should probably be a property of the Animation object
rather than specified at 'start' time. It may even be embedded 
in the GIF.

=cut

#
# This almost works for changing the animation on the fly
# but does not resize things correctly
#

sub gif_sequence
{
 my ($obj,%args) = @_;
 my $widget = $obj->MainWindow;
 my @images;
 local $@;
 while (1)
  {
   my $index = @images;
   $args{'-format'} = "gif -index $index";
   my $img;
   eval 
    {local $SIG{'__DIE__'};  
     my $img = $widget->Photo(%args);
     push(@images,$img);
    };
   last if $@;
  }
 if (@images)
  {
   delete $obj->{'_frames_'};
   $obj->add_frame(@images);
   $obj->configure(-width => 0, -height => 0);
   $obj->set_frame(0);
  }
}


