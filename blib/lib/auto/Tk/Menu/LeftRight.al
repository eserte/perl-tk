# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# LeftRight --
# This procedure is invoked to handle "left" and "right" traversal
# motions in menus. It traverses to the next menu in a menu bar,
# or into or out of a cascaded menu.
#
# Arguments:
# menu - The menu that received the keyboard
# event.
# direction - Direction in which to move: "left" or "right"
sub LeftRight
{
 my $menu = shift;
 my $direction = shift;
 # First handle traversals into and out of cascaded menus.
 if ($direction eq "right")
  {
   $count = 1;
   if ($menu->typeIS("active","cascade"))
    {
     $menu->postcascade("active");
     $m2 = $menu->entrycget("active","-menu");
     $m2->FirstEntry if (defined $m2);
     return;
    }
  }
 else
  {
   $count = -1;
   $m2 = $menu->parent;
   if ($m2->IsMenu)
    {
     $menu->activate("none");
     $m2->focus();
     # This code unposts any posted submenu in the parent.
     $tmp = $m2->index("active");
     $m2->activate("none");
     $m2->activate($tmp);
     return;
    }
  }
 # Can't traverse into or out of a cascaded menu. Go to the next
 # or previous menubutton, if that makes sense.
 $w = $Tk::postedMb;
 if ($w eq "")
  {
   return;
  }
 my @buttons = $w->parent->children;
 $length = @buttons;
 $i = Tk::lsearch(\@buttons,$w)+$count;
 while (1)
  {
   while ($i < 0)
    {
     $i += $length
    }
   while ($i >= $length)
    {
     $i += -$length
    }
   $mb = $buttons[$i];
   last if ($mb->IsMenubutton && $mb->cget("-state") ne "disabled"
            && defined($mb->cget('-menu'))
            && $mb->cget('-menu')->index('last') ne 'none'
           );
   return if ($mb == $w);
   $i += $count
  }
 $mb->PostFirst();
}

1;
