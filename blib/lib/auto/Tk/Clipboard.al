# NOTE: Derived from blib/lib/Tk.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk;

#line 620 "blib/lib/Tk.pm (autosplit into blib/lib/auto/Tk/Clipboard.al)"
sub Clipboard
{my $w = shift;
 my $cmd    = shift;
 croak "Use clipboard\u$cmd()";
}

# end of Tk::Clipboard
1;
