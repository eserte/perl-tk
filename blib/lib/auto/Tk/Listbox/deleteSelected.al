# NOTE: Derived from ../blib/lib/Tk/Listbox.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Listbox;

#line 474 "../blib/lib/Tk/Listbox.pm (autosplit into ../blib/lib/auto/Tk/Listbox/deleteSelected.al)"
sub deleteSelected
{
 my $w = shift;
 my $i;
 foreach $i (reverse $w->curselection)
  {
   $w->delete($i);
  }
}

# end of Tk::Listbox::deleteSelected
1;
