# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub focusSave
{
 my ($w) = @_;
 my $focus = $w->focusCurrent;
 return sub {} if (!defined $focus);
 return sub { eval {local $SIG{'__DIE__'};  $focus->focus } };
}

1;
