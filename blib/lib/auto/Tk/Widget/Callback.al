# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub Callback
{
 my $w = shift;
 my $name = shift;
 my $cb = $w->cget($name);
 return $cb->Call(@_) if (defined $cb);
 return (wantarray) ? () : undef;
}

1;
