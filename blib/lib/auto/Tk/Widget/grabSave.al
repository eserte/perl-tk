# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub grabSave
{
 my ($w) = @_;
 my $grab = $w->grabCurrent;
 return sub {} if (!defined $grab);
 my $method = ($grab->grabStatus eq 'global') ? 'grabGlobal' : 'grab';
 return sub { eval {local $SIG{'__DIE__'};  $grab->$method() } };
}

1;
