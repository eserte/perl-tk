package Tk::Wm;
require Tk;

use strict qw(vars);

# There are issues with this stuff now we have Tix's wm release/capture
# as toplevel-ness is now dynamic.

BEGIN 
{
 my $fn; 
 foreach $fn (qw(aspect client colormapwindows command deiconify focusmodel
		frame geometry grid group iconbitmap iconify iconmask
		iconname iconposition iconwindow maxsize minsize
		overrideredirect positionfrom protocol resizable saveunder
		sizefrom state title transient withdraw))
 {
  *{"$fn"} = sub { shift->wm("$fn",@_) };
 }
}

sub SetBindtags
{
 my ($obj) = @_;
 $obj->bindtags([ref($obj),$obj,'all']);
}

sub Post
{
 my ($w,$X,$Y) = @_;
 $X = int($X);
 $Y = int($Y);
 $w->geometry("+$X+$Y");
 $w->deiconify;
 $w->raise;
}

sub AnchorAdjust
{
 my ($anchor,$X,$Y,$w,$h) = @_;
 $anchor = 'c' unless (defined $anchor);
 $Y += ($anchor =~ /s/) ? $h : ($anchor =~ /n/) ? 0 : $h/2;
 $X += ($anchor =~ /e/) ? $w : ($anchor =~ /w/) ? 0 : $w/2;
 return ($X,$Y);
}

sub Populate
{
 my ($cw,$args) = @_;
 $cw->ConfigSpecs('-overanchor' => ['PASSIVE',undef,undef,undef],
                  '-popanchor'  => ['PASSIVE',undef,undef,undef],
                  '-popover'    => ['PASSIVE',undef,undef,undef] 
                 );
}

sub Popup
{
 my $w = shift;
 $w->configure(@_) if @_;
 $w->idletasks;
 my ($mw,$mh) = ($w->reqwidth,$w->reqheight);
 my ($rx,$ry,$rw,$rh) = (0,0,0,0);
 my $base    = $w->cget('-popover');
 my $outside = 0;
 if (defined $base)
  {
   if ($base eq 'cursor')
    {
     ($rx,$ry) = $w->pointerxy;
    }
   else
    {
     $rx = $base->rootx; 
     $ry = $base->rooty; 
     $rw = $base->Width; 
     $rh = $base->Height;
    }
  }
 else
  {
   my $sc = $w->parent->toplevel;
   $rx = -$sc->vrootx;
   $ry = -$sc->vrooty;
   $rw = $w->screenwidth;
   $rh = $w->screenheight;
  }
 my ($X,$Y) = AnchorAdjust($w->cget('-overanchor'),$rx,$ry,$rw,$rh);
 ($X,$Y)    = AnchorAdjust($w->cget('-popanchor'),$X,$Y,-$mw,-$mh);
 $w->Post($X,$Y);
}

1;
__END__


