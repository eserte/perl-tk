# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

sub CancelRepeat
{
 my $w = shift->MainWindow;
 my $id = delete $w->{_afterId_};
 $w->after('cancel',$id) if (defined $id);
}

1;
