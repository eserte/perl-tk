# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

sub idletasks
{
 shift->update('idletasks');
}

1;
