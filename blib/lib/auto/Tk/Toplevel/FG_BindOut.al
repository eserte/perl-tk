# NOTE: Derived from blib/lib/Tk/Toplevel.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Toplevel;

#line 130 "blib/lib/Tk/Toplevel.pm (autosplit into blib/lib/auto/Tk/Toplevel/FG_BindOut.al)"
# tkFocusGroup_BindOut --
#
#	Add a widget into the "FocusOut" list of the focus group. The
#	$cmd will be called when the widget loses the focus (User
#	types Tab or click on another widget).
#
sub FG_BindOut {
    my($t, $w, $cmd) = @_;
    $t->Error("focus group \"$t\" doesn't exist") unless (exists $t->{'_fg'});
    $t->{'_FocusOut'}{$w} = Tk::Callback->new($cmd);
}

# end of Tk::Toplevel::FG_BindOut
1;
