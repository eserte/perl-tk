# NOTE: Derived from blib/lib/Tk.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk;

#line 590 "blib/lib/Tk.pm (autosplit into blib/lib/auto/Tk/TraverseToMenu.al)"
# tkTraverseToMenu --
# This procedure implements keyboard traversal of menus. Given an
# ASCII character "char", it looks for a menubutton with that character
# underlined. If one is found, it posts the menubutton's menu
#
# Arguments:
# w - Window in which the key was typed (selects
# a toplevel window).
# char - Character that selects a menu. The case
# is ignored. If an empty string, nothing
# happens.
sub TraverseToMenu
{
 my $w = shift;
 my $char = shift;
 return unless(defined $char && $char ne "");
 $w = $w->toplevel->FindMenu($char);
}

# end of Tk::TraverseToMenu
1;
