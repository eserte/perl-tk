# NOTE: Derived from .././blib/lib/Tk/Ghostscript.pm.  Changes made here will be lost.
package Tk::Ghostscript;

sub StartInterp
{
 my $w = shift;
 $w->StopInterp;
 $w->idletasks;
 $w->MakeWindowExist;
 my $win  = ${$w->WindowId};  # Window for properties/events
 my $dest = ${$w->WindowId};  # Xid of drawable to draw on (gs3 and later)
 $ENV{'GHOSTVIEW'} = sprintf("%d %d",$win,$dest);
 $w->property('set','GHOSTVIEW','STRING',8,
              sprintf("%d %d %d %d %d %d %g %g %d %d %d %d",
               $w->{'bpixmap'},
               $w->{'page_orientation'},
               @{$w->{'BoundingBox'}},
               $w->{'x_pixels_per_inch'}, $w->{'y_pixels_per_inch'},
               @{$w->{'Margins'}}));
 my $screen = $w->Screen;
# my $bg = $screen->WhitePixelOfScreen;
# my $fg = $screen->BlackPixelOfScreen;
# $w->property('set','GHOSTVIEW_COLORS','STRING',8,sprintf("Monochrome %d %d",$fg,$bg));
 $w->{'Pending'} = [];
 $w->XSync(0);
 my $fh = $w->{'FH'};
 $w->{'pid'} = open($fh,"| gs -sDEVICE=x11 -dQUIET -dNOPAUSE -");
 my $fl = fcntl($fh,F_GETFL,0);
 die "Cannot F_GETFL:$!" unless (defined $fl);
 fcntl($fh,F_SETFL,$fl | O_NONBLOCK) || die "Cannot F_SETFL:$!";
}

1;
