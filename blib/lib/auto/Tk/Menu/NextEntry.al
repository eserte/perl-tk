# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# NextEntry --
# Activate the next higher or lower entry in the posted menu,
# wrapping around at the ends. Disabled entries are skipped.
#
# Arguments:
# menu - Menu window that received the keystroke.
# count - 1 means go to the next lower entry,
# -1 means go to the next higher entry.
sub NextEntry
{
 my $menu = shift;
 my $count = shift;
 if ($menu->index("last") eq "none")
  {
   return;
  }
 $length = $menu->index("last")+1;
 $active = $menu->index("active");
 if ($active eq "none")
  {
   $i = 0
  }
 else
  {
   $i = $active+$count
  }
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
   $state = eval {local $SIG{__DIE__};  $menu->entrycget($i,"-state") };
   last if (defined($state) && $state ne "disabled");
   return if ($i == $active);
   $i += $count
  }
 $menu->activate($i);
 $menu->postcascade($i)
}

1;
