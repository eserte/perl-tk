# NOTE: Derived from ./blib/lib/Tk/Checkbutton.pm.  Changes made here will be lost.
package Tk::Checkbutton;

sub Invoke
{
 my $w = shift;
 $w->invoke() unless($w->cget("-state") eq "disabled");
}

1;
1;
