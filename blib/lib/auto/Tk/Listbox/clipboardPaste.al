# NOTE: Derived from ../blib/lib/Tk/Listbox.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Listbox;

#line 484 "../blib/lib/Tk/Listbox.pm (autosplit into ../blib/lib/auto/Tk/Listbox/clipboardPaste.al)"
sub clipboardPaste
{
 my $w = shift;
 my $index = $w->index('active') || $w->index($w->XEvent->xy);
 my $str;
 eval {local $SIG{__DIE__}; $str = $w->clipboardGet };
 return if $@;
 foreach (split("\n",$str))
  {
   $w->insert($index++,$_);
  }
}      

# end of Tk::Listbox::clipboardPaste
1;
