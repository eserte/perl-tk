# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 796 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/Tags.al)"
sub Tags
{
 my $w = shift;
 my $name;
 my @result = ();
 foreach $name ($w->tagNames(@_))
  {
   push(@result,$w->Tag($name));
  }
 return @result;
}

# end of Tk::Text::Tags
1;
