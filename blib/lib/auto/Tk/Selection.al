# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

# These wrappers don't use method syntax so need to live
# in same package as raw Tk routines are newXS'ed into.

sub Selection
{my $widget = shift;
 my $cmd    = shift;
 croak "Use SelectionOwn/SelectionOwner" if ($cmd eq 'own');
 croak "Use Selection\u$cmd()";
}

1;
