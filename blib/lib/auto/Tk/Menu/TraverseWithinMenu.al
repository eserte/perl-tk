# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# tkTraverseWithinMenu
# This procedure implements keyboard traversal within a menu. It
# searches for an entry in the menu that has "char" underlined. If
# such an entry is found, it is invoked and the menu is unposted.
#
# Arguments:
# w - The name of the menu widget.
# char - The character to look for; case is
# ignored. If the string is empty then
# nothing happens.
sub TraverseWithinMenu
{
 my $w = shift;
 my $char = shift;
 return unless (defined $char);
 $char = "\L$char";
 my $last = $w->index("last");
 return if ($last eq "none");
 for ($i = 0;$i <= $last;$i += 1)
  {
   my $label = eval {local $SIG{__DIE__};  $w->entrycget($i,"-label") };
   next unless defined($label);
   my $ul = $w->entrycget($i,"-underline");
   if (defined $ul && $ul >= 0)
    {
     $label = substr("\L$label",$ul,1);
     if (defined($label) && $label eq $char)
      {
       if ($w->type($i) eq 'cascade')
        {
         $w->postcascade($i);
         $w->activate($i);
         my $m2 = $w->entrycget($i,'-menu');
         $m2->FirstEntry if (defined $m2);
        }
       else
        {
         $w->Unpost();  
         $w->invoke($i);
        }
       return;
      }
    }
  }
}

1;
