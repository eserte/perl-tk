# NOTE: Derived from ./blib/lib/Tk/Radiobutton.pm.  Changes made here will be lost.
package Tk::Radiobutton;

sub Invoke
{
 my $w = shift;
 $w->invoke() unless($w->cget("-state") eq "disabled");
}

1;
1;
