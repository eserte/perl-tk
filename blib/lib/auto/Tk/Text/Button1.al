# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 348 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/Button1.al)"
# Button1 --
# This procedure is invoked to handle button-1 presses in text
# widgets. It moves the insertion cursor, sets the selection anchor,
# and claims the input focus.
#
# Arguments:
# w - The text window in which the button was pressed.
# x - The x-coordinate of the button press.
# y - The x-coordinate of the button press.
sub Button1
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 $Tk::selectMode = 'char';
 $Tk::mouseMoved = 0;
 $w->markSet('insert',"@".$x.",".$y);
 $w->markSet('anchor','insert');
 $w->focus() if ($w->cget("-state") eq 'normal');
 $w->tag('remove','sel','1.0','end');
}

# end of Tk::Text::Button1
1;
