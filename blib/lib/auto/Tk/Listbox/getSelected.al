# NOTE: Derived from ../blib/lib/Tk/Listbox.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Listbox;

#line 497 "../blib/lib/Tk/Listbox.pm (autosplit into ../blib/lib/auto/Tk/Listbox/getSelected.al)"
sub getSelected
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
__END__
1;
# end of Tk::Listbox::getSelected
