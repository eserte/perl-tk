# NOTE: Derived from .././blib/lib/Tk/Web.pm.  Changes made here will be lost.
package Tk::Web;

sub ShowHTML
{
 my ($w) = @_;
 $w->TextPopup(HTML => $w->html->as_HTML);
}

1;
