# Copyright (c) 1995-1997 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Wm;
use AutoLoader;

require Tk::Widget;
*AUTOLOAD = \&Tk::Widget::AUTOLOAD;

use strict qw(vars);

# There are issues with this stuff now we have Tix's wm release/capture
# as toplevel-ness is now dynamic.


use vars qw($VERSION);
$VERSION = '2.010'; # $Id: //depot/Tk/Tk/Wm.pm#10$

use Tk::Submethods ( 'wm' => [qw(grid)] );

Direct Tk::Submethods ('wm' => [qw(aspect client colormapwindows command 
                       deiconify focusmodel frame geometry group
                       iconbitmap iconify iconmask iconname
                       iconwindow maxsize minsize overrideredirect positionfrom
                       protocol resizable saveunder sizefrom state title transient
                       withdraw)]);

sub SetBindtags
{
 my ($obj) = @_;
 $obj->bindtags([ref($obj),$obj,'all']);
}

sub Populate
{
 my ($cw,$args) = @_;
 $cw->ConfigSpecs('-overanchor' => ['PASSIVE',undef,undef,undef],
                  '-popanchor'  => ['PASSIVE',undef,undef,undef],
                  '-popover'    => ['PASSIVE',undef,undef,undef] 
                 );
}

1;

__END__

sub Post
{
 my ($w,$X,$Y) = @_;
 $X = int($X);
 $Y = int($Y);
 $w->positionfrom('program');
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
   my $sc = ($w->parent) ? $w->parent->toplevel : $w;
   $rx = -$sc->vrootx;
   $ry = -$sc->vrooty;
   $rw = $w->screenwidth;
   $rh = $w->screenheight;
  }
 my ($X,$Y) = AnchorAdjust($w->cget('-overanchor'),$rx,$ry,$rw,$rh);
 ($X,$Y)    = AnchorAdjust($w->cget('-popanchor'),$X,$Y,-$mw,-$mh);
 $w->Post($X,$Y);
}

sub FullScreen
{
 my $w = shift;
 my $over = (@_) ? shift : 0;
 $w->GeometryRequest($w->screenwidth,$w->screenheight);
 $w->overrideredirect($over);
 $w->Post(0,0);
}

sub iconposition
{
 my $w = shift;
 return $w->wm('iconposition',$1,$2) if (@_ == 1 && $_[0] =~ /^(\d+),(\d+)$/); 
 $w->wm('iconposition',@_);
}
