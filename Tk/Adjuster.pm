package Tk::Adjuster::Item;
@ISA = qw(Tk::Frame);

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<B1-Motion>',['Motion',1]);
 $mw->bind($class,'<Shift-B1-Motion>',['Motion',0]);
 $mw->bind($class,'<ButtonRelease-1>',['Motion',0]);
 return $class;
}

sub dx
{
 my $w = shift;
 my $ev = $w->XEvent;
 my $x = $ev->x;                                   
 if ($x > 0)                                       
  {                                                
   $x -= $w->Width;                                
   return 0 if $x < 0;                               
  }                                                
 return $x;
}

sub dy
{
 my $w = shift;
 my $ev = $w->XEvent;
 my $y = $ev->y;                                   
 if ($y > 0)                                       
  {                                                
   $y -= $w->Height;                                
   return 0 if $y < 0;                               
  }                                                
 return $y;
}

sub right
{
 my $w = shift;
 my $dx = $w->dx;
 $w->Parent->dWidth(-$dx,$dx,@_) if $dx;
}

sub left
{
 my $w = shift;
 my $dx = $w->dx;
 $w->Parent->dWidth($dx,$dx,@_) if $dx;
}

sub bottom
{
 my $w = shift;
 my $dy = $w->dy;
 $w->Parent->dHeight(-$dy,$dy,@_) if $dy;
}

sub top
{
 my $w = shift;
 my $dy = $w->dy;
 $w->Parent->dHeight($dy,$dy,@_) if $dy;
}

sub Motion
{
 my $w = shift;
 my $p  = $w->Parent;
 my $side = $p->cget('-side');
 $w->$side(@_);
}

package Tk::Adjuster;
use AutoLoader;
require Tk::Frame;
@ISA = qw(Tk::Frame);

Construct Tk::Widget qw(Adjuster);

# We cannot do this :

# Construct Tk::Widget 'packAdjust';

# because if managed object is Derived (e.g. a Scrolled) then our 'new'
# will be delegated and hierachy gets turned inside-out
# So packAdjust is autoloaded in Widget.pm

sub packed
{
 my ($w,$s,%args) = @_;
 delete $args{'-before'};
 $args{'-expand'} = 0;
 $args{'-after'} = $s;
 $args{'-fill'} = (($w->vert) ? 'y' : 'x');
 $w->pack(%args);
}

sub gridded
{
 my ($w,$s,%args) = @_;
 # delete $args{'-before'};
 # $args{'-expand'} = 0;
 # $args{'-after'} = $s;
 # $args{'-fill'} = (($w->vert) ? 'y' : 'x');
 $w->grid(%args);
}

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<Configure>','SizeChange');
 $mw->bind($class,'<Unmap>','Restore');
 $mw->bind($class,'<Map>','Mapped');
 return $class;
}

sub SizeChange
{
 my $w = shift;
 if ($w->vert)
  {
   my $sx = ($w->Width - $w->{'sep'}->Width)/2;
   $w->{'but'}->place('-x' => 0, '-y' => $w->Height-18);
   $w->{'sep'}->place('-x' => $sx, '-y' => 0,  -relheight => 1);
   $w->configure(-width => $w->{'but'}->ReqWidth);
  }
 else
  {
   my $sy = ($w->Height - $w->{'sep'}->Height)/2;
   $w->{'but'}->place('-x' => $w->Width-18, '-y' => 0);
   $w->{'sep'}->place('-x' => 0, '-y' => $sy,  -relwidth => 1);
   $w->configure(-height => $w->{'but'}->ReqHeight);
  }
}

sub Mapped
{
 my $w = shift;
 my $m = $w->manager;
 if ($m =~ /^(pack|grid)$/)
  {
   my %info = $w->$m('info');
   $info{'-in'}->$m('propagate',0);
  }
}

sub Populate
{
 my ($w,$args) = @_;
 $w->SUPER::Populate($args);
 $w->{'sep'} = Tk::Adjuster::Item->new($w,-bd => 1, -relief => 'sunken');
 $w->{'but'} = Tk::Adjuster::Item->new($w,-bd => 1, -width => 8, -height => 8, -relief => 'raised');
 # Use a Menu as a "token"
 # Toplevel needs these, Menu implies them
 # $l->UnmapWindow;
 # $l->overrideredirect(1);
 my $l = $w->{'lin'} = $w->Menu;
 my $cs = $w->ConfigSpecs(-widget => ['PASSIVE','widget','Widget',$w->Parent],
                 -side       => ['METHOD','side','Side','top'],
                 -delay      => ['PASSIVE','delay','Delay', 1],
                 -background => [[SELF,$w->{'sep'},$w->{'but'}],'background','Background',undef], 
                 -foreground => [Tk::Configure->new($w->{'lin'},'-background'),'foreground','Foreground','black'] 
                );
}

sub side
{
 my ($w,$val) = @_; 
 if (@_ > 1)
  {
   $w->{'side'} = $val;
   my $cursor;                                                                           
   if ($w->vert)                                                                         
    {                                                                                    
     $cursor = 'sb_h_double_arrow';                                                      
     $w->{'sep'}->configure(-width => 2, -height => 10000);                              
    }                                                                                    
   else                                                                                  
    {                                                                                    
     $cursor = 'sb_v_double_arrow';                                                      
     $w->{'sep'}->configure(-height => 2, -width => 10000);                              
    }                                                                                    
   my $x;                                                                                
   foreach $x ($w->{'sep'},$w->{'but'})                                                  
    {                                                                                    
     $x->configure(-cursor => $cursor);                                                  
    }                                                                                    
  }
 return $w->{'side'};
}

sub slave 
{ 
 my $w = shift;
 my $s = $w->cget('-widget');
 return $s;
}

sub vert
{
 my $w = shift;
 my $side = $w->cget('-side');
 return  1 if $side eq 'left';
 return -1 if $side eq 'right';
 return  0;
}

1;
__END__

=head1 NAME

Tk::Adjuster, packAdjust - Allow size of packed widgets to be adjusted by user

=head1 SYNOPSIS

  use Tk;
  use Tk::Adjuster;

  $widget->packAdjust([pack options]);

=head1 DESCRIPTION

C<packAdjust> calls pack on the widget and then creates an instance of 
Tk::Adjuster and packs that "after" the widget. Tk::Adjust is a Frame
containing a "line" and a blob. 

Dragging either with Mouse Button-1 results in a line being dragged 
to indicate new size. Releasing Button submits GeometryRequests 
on behalf of the widget which will cause the packer to change widget's size. 

If Drag is done with Shift button down, then GeometryRequests are made
in "real time" so that text-flow effects can be seen, but as a lot more
work is done behaviour may be sluggish.


If widget is packed with -side => left or -side => right then width is 
adjusted. If packed -side => top or -side => bottom then height is adjusted.

C<packPropagate> is turned off for the master window to prevent adjustment
changing overall window size. Similarly C<packPropagate> is turned off
for the managed widget if it has things packed inside it. This is so that 
the GeometryRequests that Tk::Adjuster are not overriden by pack.

=head1 NOTES

The 'line' which is used to feedback position is in fact a 'Menu' widget
set to an unorthodox shape, and with a black background.

=head1 BUGS

If the size of adjustable widget is increased to the limit there is no longer
room for the Tk::Ajuster widget. As a work-round it forcibly makes room for 
itself if it is unmapped. However the "grab" it held will have been lost 
and button-motion events may be sent to other widgets which are not expecting 
them, which can result in error messages. 

=cut 

sub Restore
{
 my $w = shift;
 if ($w->vert)
  {
   $w->dWidth(-$w->ReqWidth);
  }
 else
  {
   $w->dHeight(-$w->ReqHeight);
  }
}

sub dWidth
{
 my ($w,$dx,$sdx,$down) = @_;
 my $l = $w->{'lin'};
 if ($down && $w->cget('-delay'))
  {
   my $r = $w->{'sep'};
   $l->GeometryRequest(1,$r->Height) unless $l->IsMapped;
   $l->MoveToplevelWindow($sdx+$r->rootx,$r->rooty);
   $l->MapWindow unless ($l->IsMapped);
   $l->XRaiseWindow;
  }
 else
  {
   $l->UnmapWindow;
   my $s = $w->slave;
   $s->GeometryRequest($s->Width+$dx,$s->Height) if (defined $s);
  }
 $w->idletasks;
}

sub dHeight
{
 my ($w,$dy,$sdy,$down) = @_;
 my $l = $w->{'lin'};
 if ($down && $w->cget('-delay'))
  {
   my $r = $w->{'sep'};
   $l->GeometryRequest($r->Width,1) unless $l->IsMapped;
   $l->MoveToplevelWindow($r->rootx,$r->rooty+$sdy);
   $l->MapWindow unless $l->IsMapped;
   $l->XRaiseWindow;
  }
 else
  {
   $l->UnmapWindow;
   my $s = $w->slave;
   $s->GeometryRequest($s->Width,$s->Height+$dy) if (defined $s);
  }
 $w->idletasks;
}



