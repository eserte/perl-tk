# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

sub wordstart
{my ($w,$pos) = @_;
 my $string = $w->get;
 $pos = $w->index("insert")-1 unless(defined $pos);
 $string = substr($string,0,$pos);
 $string =~ s/\S*$//;
 length $string;
}

1;
