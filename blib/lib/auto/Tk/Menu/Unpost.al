# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# Unpost --
# This procedure unposts a given menu, plus all of its ancestors up
# to (and including) a menubutton, if any. It also restores various
# values to what they were before the menu was posted, and releases
# a grab if there's a menubutton involved. Special notes:
# 1. It's important to unpost all menus before releasing the grab, so
# that any Enter-Leave events (e.g. from menu back to main
# application) have mode NotifyGrab.
# 2. Be sure to enclose various groups of commands in "catch" so that
# the procedure will complete even if the menubutton or the menu
# or the grab window has been deleted.
#
# Arguments:
# menu - Name of a menu to unpost. Ignored if there
# is a posted menubutton.
sub Unpost
{
 my $menu = shift;
 my $mb = $Tk::postedMb;

 # Restore focus right away (otherwise X will take focus away when
 # the menu is unmapped and under some window managers (e.g. olvwm)
 # we'll lose the focus completely).

 eval {local $SIG{__DIE__}; $Tk::focus->focus() } if (defined $Tk::focus);
 undef $Tk::focus;

 # Unpost menu(s) and restore some stuff that's dependent on
 # what was posted.
 eval {local $SIG{__DIE__}; 
   if (defined $mb)
     {
      $menu = $mb->cget("-menu");
      $menu->unpost();
      $Tk::postedMb = undef;
      $mb->configure("-cursor",$Tk::cursor);
      $mb->configure("-relief",$Tk::relief)
     }
    elsif (defined $Tk::popup)
     {
      $Tk::popup->unpost();
      undef $Tk::popup;
     }
    elsif (defined $menu && ref $menu && $menu->transient)
     {
      # We're in a cascaded sub-menu from a torn-off menu or popup.
      # Unpost all the menus up to the toplevel one (but not
      # including the top-level torn-off one) and deactivate the
      # top-level torn off menu if there is one.
      while (1)
       {
        $parent = $menu->parent;
        last if (!$parent->IsMenu || !$parent->ismapped);
        $parent->postcascade("none");
        last if (!$parent->transient);
        $menu = $parent
       }
      $menu->unpost()
     }
  };
 warn "$@" if ($@);
 # Release grab, if any.
 if (defined $menu && ref $menu)
  {
   my $grab = $menu->grabCurrent;
   $grab->grabRelease if (defined $grab);
  }
}

1;
