# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

# Motion --
# This procedure handles mouse motion events inside menubuttons, and
# also outside menubuttons when a menubutton has a grab (e.g. when a
# menu selection operation is in progress).
#
# Arguments:
# w - The name of the menubutton widget.
# upDown - "down" means button 1 is pressed, "up" means
# it isn't.
# rootx, rooty - Coordinates of mouse, in (virtual?) root window.
sub Motion
{
 my $w = shift;
 my $upDown = shift;
 my $rootx = shift;
 my $rooty = shift;
 return if (defined($Tk::inMenubutton) && $Tk::inMenubutton == $w);
 my $new = $w->Containing($rootx,$rooty) if defined $w->Containing($rootx,$rooty);
 return if ! defined $new;
 if (defined($Tk::inMenubutton) && $new != $Tk::inMenubutton)
  {
   $Tk::inMenubutton->Leave();
  }
 if (defined($new) && $new->IsMenubutton && $new->cget('-indicatoron') == 0)
  {
   if ($upDown eq "down")
    {
     $new->Post($rootx,$rooty);
    }
   else
    {
     $new->Enter();
    }
  }
}

1;
