# NOTE: Derived from blib/lib/Tk/Toplevel.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Toplevel;

#line 88 "blib/lib/Tk/Toplevel.pm (autosplit into blib/lib/auto/Tk/Toplevel/FG_Create.al)"
#----------------------------------------------------------------------
#
#			Focus Group
#
# Focus groups are used to handle the user's focusing actions inside a
# toplevel.
#
# One example of using focus groups is: when the user focuses on an
# entry, the text in the entry is highlighted and the cursor is put to
# the end of the text. When the user changes focus to another widget,
# the text in the previously focused entry is validated.
#

#----------------------------------------------------------------------
# tkFocusGroup_Create --
#
#	Create a focus group. All the widgets in a focus group must be
#	within the same focus toplevel. Each toplevel can have only
#	one focus group, which is identified by the name of the
#	toplevel widget.
#
sub FG_Create {
    my $t = shift;
    unless (exists $t->{'_fg'}) {
	$t->{'_fg'} = 1;
	$t->bind('<FocusIn>', sub {
		     my $w = shift;
		     my $Ev = $w->XEvent;
		     $t->FG_In($w, $Ev->d);
		 }
		);
	$t->bind('<FocusOut>', sub {
		     my $w = shift;
		     my $Ev = $w->XEvent;
		     $t->FG_Out($w, $Ev->d);
		 }
		);
	$t->bind('<Destroy>', sub {
		     my $w = shift;
		     my $Ev = $w->XEvent;
		     $t->FG_Destroy($w);
		 }
		);
    }
}

# end of Tk::Toplevel::FG_Create
1;
