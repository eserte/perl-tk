# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# FindName --
# Given a menu and a text string, return the index of the menu entry
# that displays the string as its label. If there is no such entry,
# return an empty string. This procedure is tricky because some names
# like "active" have a special meaning in menu commands, so we can't
# always use the "index" widget command.
#
# Arguments:
# menu - Name of the menu widget.
# s - String to look for.
sub FindName
{
 my $menu = shift;
 my $s = shift;
 my $i = undef;
 if ($s !~ /^active$|^last$|^none$|^[0-9]|^@/)
  {
   $i = eval {local $SIG{__DIE__};  $menu->index($s) };
   return $i;
  }
 my $last = $menu->index("last");
 return if ($last eq 'none');
 for ($i = 0;$i <= $last;$i += 1)
  {
   my $label = eval {local $SIG{__DIE__};  $menu->entrycget($i,"-label") };
   return $i if (defined $label && $label eq $s);
  }
 return undef;
}

1;
