# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

# a wrapper on eval which turns off user $SIG{__DIE__}
sub catch (&)
{
 my $sub = shift;
 eval {local $SIG{'__DIE__'}; &$sub };
}

1;
