# NOTE: Derived from blib/lib/Tk.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk;

#line 387 "blib/lib/Tk.pm (autosplit into blib/lib/auto/Tk/CancelRepeat.al)"
sub CancelRepeat
{
 my $w = shift->MainWindow;
 my $id = delete $w->{_afterId_};
 $w->after('cancel',$id) if (defined $id);
}

# end of Tk::CancelRepeat
1;
