# NOTE: Derived from blib/lib/Tk/Toplevel.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Toplevel;

#line 118 "blib/lib/Tk/Toplevel.pm (autosplit into blib/lib/auto/Tk/Toplevel/FG_BindIn.al)"
# tkFocusGroup_BindIn --
#
# Add a widget into the "FocusIn" list of the focus group. The $cmd will be
# called when the widget is focused on by the user.
#
sub FG_BindIn {
    my($t, $w, $cmd) = @_;
    $t->Error("focus group \"$t\" doesn't exist") unless (exists $t->{'_fg'});
    $t->{'_FocusIn'}{$w} = Tk::Callback->new($cmd);
}

# end of Tk::Toplevel::FG_BindIn
1;
