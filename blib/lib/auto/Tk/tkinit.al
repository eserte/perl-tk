# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

sub tkinit
{
 return MainWindow->new(@_);
}

1;
