# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

# Post --
# Given a menubutton, this procedure does all the work of posting
# its associated menu and unposting any other menu that is currently
# posted.
#
# Arguments:
# w - The name of the menubutton widget whose menu
# is to be posted.
# x, y - Root coordinates of cursor, used for positioning
# option menus. If not specified, then the center
# of the menubutton is used for an option menu.
sub Post
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 return if ($w->cget("-state") eq "disabled");
 return if (defined $Tk::postedMb && $w == $Tk::postedMb);
 my $menu = $w->cget("-menu");
 return unless (defined($menu) && $menu->index('last') ne 'none');

 my $wpath = $w->PathName;
 my $mpath = $menu->PathName;
 unless (index($mpath,"$wpath.") == 0)
  {
   die "Cannot post $mpath : not a descendant of $wpath";
  }

 my $cur = $Tk::postedMb;
 if (defined $cur)
  {
   Tk::Menu->Unpost(undef); # fixme
  }
 $Tk::cursor = $w->cget("-cursor");
 $Tk::relief = $w->cget("-relief");
 $w->configure("-cursor","arrow");
 $w->configure("-relief","raised");
 $Tk::postedMb = $w;
 $Tk::focus = $w->focusCurrent;
 $menu->activate("none");
 # If this looks like an option menubutton then post the menu so
 # that the current entry is on top of the mouse. Otherwise post
 # the menu just below the menubutton, as for a pull-down.
 if ($w->cget("-indicatoron") == 1 && defined($w->cget("-textvariable")))
  {
   if (!defined($y))
    {
     $x = $w->rootx+$w->width/2;
     $y = $w->rooty+$w->height/2
    }
   $menu->PostOverPoint($x,$y,$menu->FindName($w->cget("-text")))
  }
 else
  {
   $menu->post($w->rootx,$w->rooty+$w->height);
  }
 $menu->Enter();
 $w->grab("-global")
}

1;
