# NOTE: Derived from blib/lib/Tk.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk;

#line 613 "blib/lib/Tk.pm (autosplit into blib/lib/auto/Tk/Selection.al)"
# These wrappers don't use method syntax so need to live
# in same package as raw Tk routines are newXS'ed into.

sub Selection
{my $widget = shift;
 my $cmd    = shift;
 croak "Use SelectionOwn/SelectionOwner" if ($cmd eq 'own');
 croak "Use Selection\u$cmd()";
}

# end of Tk::Selection
1;
