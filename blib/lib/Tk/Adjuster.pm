package Tk::Adjuster::Item;

use vars qw($VERSION @ISA);
$VERSION = '3.012'; # $Id: //depot/Tk8/Tk/Adjuster.pm#12$

use base  qw(Tk::Frame);

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
 my $x = $w->XEvent->x;                                   
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
 my $y = $w->XEvent->y;                                   
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

use vars qw($VERSION @ISA);
$VERSION = '3.012'; # $Id: //depot/Tk8/Tk/Adjuster.pm#12$

require Tk::Frame;
use base  qw(Tk::Frame);

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
 if ($m =~ /^(?:pack|grid)$/)
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
                 -background => [['SELF',$w->{'sep'},$w->{'but'}],'background','Background',undef], 
                 -foreground => [Tk::Configure->new($w->{'lin'},'-background'),'foreground','Foreground','black'] 
                );
 $w->{lastsd} = 0;
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

=cut #' emacs hilighting...

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

   my $base = $w->Parent;
   if ($sdx+$r->rootx >= $base->rootx
       && $sdx+$r->rootx < $base->rootx + $base->width)
    {
     # avoid drag hanging
     unless ($sdx == $w->{lastsd})
      {
       $l->MoveToplevelWindow($sdx+$r->rootx,$r->rooty);
       $w->{lastsd} = $sdx;
      }

     $l->MapWindow unless ($l->IsMapped);
     $l->XRaiseWindow;
    }
   # Dragged line out of parent frame the first time...
   elsif ($l->IsMapped)
    {
     $l->UnmapWindow;
    }
  }
 else
  {
   $l->UnmapWindow;
   my $s = $w->slave;
   $s->GeometryRequest($s->Width+$dx,$s->Height) if (defined $s);
   $w->XSync(1);
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

   my $base = $w->Parent;
   if ($sdy+$r->rooty >= $base->rooty
       && $sdy+$r->rooty < $base->rooty + $base->height)
    {
     # avoid drag hanging
     unless ($sdy == $w->{lastsd})
      {
       $l->MoveToplevelWindow($r->rootx,$sdy+$r->rooty);
       $w->{lastsd} = $sdy;
      }

     $l->MapWindow unless $l->IsMapped;
     $l->XRaiseWindow;
    }
   # Dragged line out of parent frame the first time...
   elsif ($l->IsMapped)
    {
     $l->UnmapWindow;
    }
  }
 else
  {
   $l->UnmapWindow;
   my $s = $w->slave;
   $s->GeometryRequest($s->Width,$s->Height+$dy) if (defined $s);
   $w->XSync(1);
  }
 $w->idletasks;
}
