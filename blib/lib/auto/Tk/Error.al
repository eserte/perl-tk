# NOTE: Derived from blib/lib/Tk.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk;

#line 375 "blib/lib/Tk.pm (autosplit into blib/lib/auto/Tk/Error.al)"
sub Error
{my $w = shift;
 my $error = shift;
 if (Exists($w))
  {
   my $grab = $w->grab('current');
   $grab->Unbusy if (defined $grab);
  }
 chomp($error);
 warn "Tk::Error: $error\n " . join("\n ",@_)."\n";
}

# end of Tk::Error
1;
