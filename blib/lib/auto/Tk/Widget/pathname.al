# NOTE: Derived from blib/lib/Tk/Widget.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Widget;

#line 1173 "blib/lib/Tk/Widget.pm (autosplit into blib/lib/auto/Tk/Widget/pathname.al)"
sub pathname
{
 my ($w,$id) = @_;
 my $x = $w->winfo('pathname',-displayof  => oct($id));
 return $x->PathName;
}

1;
# end of Tk::Widget::pathname
