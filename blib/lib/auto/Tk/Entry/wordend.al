# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

sub wordend
{my ($w,$pos) = @_;
 my $string = $w->get;
 my $anc = length $string;
 $pos = $w->index("insert") unless(defined $pos);
 $string = substr($string,$pos);
 $string =~ s/^(?:((?=\s)\s*|(?=\S)\S*))//x;
 $anc - length($string);
}

1;
