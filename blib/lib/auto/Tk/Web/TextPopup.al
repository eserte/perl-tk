# NOTE: Derived from .././blib/lib/Tk/Web.pm.  Changes made here will be lost.
package Tk::Web;

sub TextPopup
{
 my ($w,$kind,$text) = @_;
 my $t   = $w->MainWindow->Toplevel;
 my $url = $w->url;
 $t->title("$kind : ".$url->as_string);
 my $tx = $t->Scrolled('Text',-wrap => 'none')->pack(-expand => 1, -fill => 'both');
 $tx->insert('end',$text);
}

1;
