# NOTE: Derived from blib/lib/Tk/Toplevel.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Toplevel;

#line 166 "blib/lib/Tk/Toplevel.pm (autosplit into blib/lib/auto/Tk/Toplevel/FG_In.al)"
# tkFocusGroup_In --
#
#	Handles the <FocusIn> event. Calls the FocusIn command for the newly
#	focused widget in the focus group.
#
sub FG_In {
    my($t, $w, $detail) = @_;
    if (defined $t->{'_focus'} and $t->{'_focus'} eq $w) {
	# This is already in focus
	return;
    } else {
	$t->{'_focus'} = $w;
        $t->{'_FocusIn'}{$w}->Call if exists $t->{'_FocusIn'}{$w};
    }
}

# end of Tk::Toplevel::FG_In
1;
