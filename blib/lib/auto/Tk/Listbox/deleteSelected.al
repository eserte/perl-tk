# NOTE: Derived from .././blib/lib/Tk/Listbox.pm.  Changes made here will be lost.
package Tk::Listbox;

sub deleteSelected
{
 my $w = shift;
 my $i;
 foreach $i (reverse $w->curselection)
  {
   $w->delete($i);
  }
}

1;
