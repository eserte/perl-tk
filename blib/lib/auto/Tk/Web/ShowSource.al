# NOTE: Derived from .././blib/lib/Tk/Web.pm.  Changes made here will be lost.
package Tk::Web;

sub ShowSource
{
 my ($w) = @_;
 $w->TextPopup(Source => $w->html->{'_source_'});
}

1;
