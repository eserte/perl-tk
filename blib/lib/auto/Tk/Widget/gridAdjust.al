# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub gridAdjust
{
 require Tk::Adjuster;
 my ($w,%args) = @_;
 my $delay = delete($args{'-delay'});
 $delay = 1 unless (defined $delay);
 $w->grid(%args);
 %args = $w->gridInfo;
 my $adj = Tk::Adjuster->new($args{'-in'},-widget => $w, -delay => $delay);
 $adj->gridded($w,%args);
 return $w;
}

1;
