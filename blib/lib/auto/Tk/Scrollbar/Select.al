# NOTE: Derived from .././blib/lib/Tk/Scrollbar.pm.  Changes made here will be lost.
package Tk::Scrollbar;

# tkScrollSelect --
# This procedure is invoked when button 1 is pressed over the scrollbar.
# It invokes one of several scrolling actions depending on where in
# the scrollbar the button was pressed.
#
# Arguments:
# w -		The scrollbar widget.
# element -	The element of the scrollbar that was selected, such
#		as "arrow1" or "trough2".  Shouldn't be "slider".
# repeat -	Whether and how to auto-repeat the action:  "noRepeat"
#		means don't auto-repeat, "initial" means this is the
#		first action in an auto-repeat sequence, and "again"
#		means this is the second repetition or later.

sub Select 
{
 my $w = shift;
 my $element = shift;
 my $repeat  = shift;
 return unless defined ($element);
 if ($element eq "arrow1")
  {
   $w->ScrlByUnits("hv",-1);
  }
 elsif ($element eq "trough1")
  {
   $w->ScrlByPages("hv",-1);
  }
 elsif ($element eq "trough2")
  {
   $w->ScrlByPages("hv", 1);
  }
 elsif ($element eq "arrow2")
  {
   $w->ScrlByUnits("hv", 1);
  }
 else
  {
   return;
  }

 if ($repeat eq "again")
  {
   $w->RepeatId($w->after($w->cget("-repeatinterval"),["Select",$w,$element,"again"]));
  }
 elsif ($repeat eq "initial")
  {
   $w->RepeatId($w->after($w->cget("-repeatdelay"),["Select",$w,$element,"again"]));
  }
}

1;
