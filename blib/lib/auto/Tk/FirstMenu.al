# NOTE: Derived from blib/lib/Tk.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk;

#line 604 "blib/lib/Tk.pm (autosplit into blib/lib/auto/Tk/FirstMenu.al)"
# tkFirstMenu --
# This procedure traverses to the first menubutton in the toplevel
# for a given window, and posts that menubutton's menu.
#
# Arguments:
# w - Name of a window. Selects which toplevel
# to search for menubuttons.
sub FirstMenu
{
 my $w = shift;
 $w = $w->toplevel->FindMenu("");
}

# end of Tk::FirstMenu
1;
