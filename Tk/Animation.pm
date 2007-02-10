package Tk::Animation;

use vars qw($VERSION);
$VERSION = '4.007'; # $Id: //depot/Tkutf8/Tk/Animation.pm#8 $

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
 $obj->set_image( 0 );
 $obj->{_delta_} = 1;
 $obj->{_blank_} = 0;
 return $obj;
}

sub fast_forward {

    my( $self, $delta) = @_;

    $self->{_delta_} = $delta;
    if( not exists $self->{_playing_} ) {
	my $playing = exists $self->{'_NextId_'};
	$self->{_playing_} = $playing;
	$self->resume_animation if not $playing;
    } else {
	my $playing = delete $self->{_playing_};
	$self->pause_animation if not $playing;
    }

} # end fast_forward

*fast_reverse = \&fast_forward;

sub frame_count {
    my $frames = shift->{'_frames_'};
    return -1 unless $frames;
    return @$frames;
}

sub blank {
    my( $self, $blank ) = @_;
    $blank = 1 if not defined $blank;
    $self->{_blank_} = $blank;
    $blank;
}

sub set_image
{
 my ($obj,$index)  = @_;
 my $frames = $obj->{'_frames_'};
 return unless $frames && @$frames;
 $index = 0 unless $index < @$frames;
 $obj->blank if $obj->{_blank_};  # helps some make others worse
 $obj->copy($frames->[$index]);
 $obj->{'_frame_index_'} = $index;
}

sub next_image
{
 my ($obj, $delta)  = @_;
 $delta = $obj->{_delta_} unless $delta;
 my $frames = $obj->{'_frames_'};
 return unless $frames && @$frames;
 $obj->set_image((($obj->{'_frame_index_'} || 0) + $delta) % @$frames);
}

sub prev_image { shift->next_image( -1 ) }

sub pause_animation { 
    my $self = shift;
    my $id = delete $self->{'_NextId_'};
    Tk::catch { $id->cancel } if $id;
}

sub resume_animation {
    my( $self, $period ) = @_;
    if( not defined $self->{'_period_'} ) {
	$self->{'_period_'} = defined( $period ) ? $period : 100;
    }
    $period = $self->{'_period_'};
    my $w = $self->MainWindow;
    $self->{'_NextId_'} = $w->repeat( $period => [ $self => 'next_image' ] );
}

sub start_animation
{
 my ($obj,$period) = @_;
 $period ||= 100;
 my $frames = $obj->{'_frames_'};
 return unless $frames && @$frames;
 my $w = $obj->MainWindow;
 $obj->stop_animation;
 $obj->{'_period_'} = $period;
 $obj->{'_NextId_'} = $w->repeat($period,[$obj,'next_image']);
}

sub stop_animation
{
 my ($obj) = @_;
 my $id = delete $obj->{'_NextId_'};
 Tk::catch { $id->cancel } if $id;
 $obj->set_image(0);
}

1;

__END__

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

