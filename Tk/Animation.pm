package Tk::Animation;

use vars qw($VERSION @ISA);
$VERSION = '3.012'; # $Id: //depot/Tk8/Tk/Animation.pm#12$

use Tk::Photo;
use base  qw(Tk::Photo);

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

