# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub packAdjust
{
 print 'packAdjust(',join(',',@_),")\n";
 require Tk::Adjuster;
 my ($w,%args) = @_;
 my $delay = delete($args{'-delay'});
 $delay = 1 unless (defined $delay);
 $w->pack(%args);
 %args = $w->packInfo;
 my $adj = Tk::Adjuster->new($args{'-in'},
            -widget => $w, -delay => $delay, -side => $args{'-side'});
 $adj->packed($w,%args);
 return $w;
}

1;
