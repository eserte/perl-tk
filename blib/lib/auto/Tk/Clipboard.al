# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

sub Clipboard
{my $w = shift;
 my $cmd    = shift;
 croak "Use clipboard\u$cmd()";
}

1;
