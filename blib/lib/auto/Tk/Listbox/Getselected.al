# NOTE: Derived from .././blib/lib/Tk/Listbox.pm.  Changes made here will be lost.
package Tk::Listbox;

sub Getselected
{
 my ($w) = @_;
 my $i;
 my (@result) = ();
 foreach $i ($w->curselection)
  {
   push(@result,$w->get($i));
  }
 return (wantarray) ? @result : $result[0];
}

1;
