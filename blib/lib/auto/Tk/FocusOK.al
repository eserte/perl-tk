# NOTE: Derived from blib/lib/Tk.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk;

#line 524 "blib/lib/Tk.pm (autosplit into blib/lib/auto/Tk/FocusOK.al)"
sub FocusOK
{
 my $w = shift;
 my $value;
 catch { $value = $w->cget('-takefocus') };
 if (!$@ && defined($value))
  {
   return 0 if ($value eq '0');
   return $w->viewable if ($value eq '1');
   $value = $w->$value();
   return $value if (defined $value);
  }
 if (!$w->viewable)
  {
   return 0;
  }
 catch { $value = $w->cget('-state') } ;
 if (!$@ && defined($value) && $value eq "disabled")
  {
   return 0;
  }
 $value = grep(/Key|Focus/,$w->Tk::bind(),$w->Tk::bind(ref($w)));
 return $value;
}

# end of Tk::FocusOK
1;
