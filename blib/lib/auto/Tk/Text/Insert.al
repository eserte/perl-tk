# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

# Insert --
# Insert a string into a text at the point of the insertion cursor.
# If there is a selection in the text, and it covers the point of the
# insertion cursor, then delete the selection before inserting.
#
# Arguments:
# w - The text window in which to insert the string
# s - The string to insert (usually just a single character)
sub Insert
{
 my $w = shift;
 my $s = shift;
 return unless (defined $s && $s ne '');
 Tk::catch
  {
   if ($w->compare("sel.first","<=",'insert') && 
       $w->compare("sel.last",">=",'insert'))
     {
      $w->delete("sel.first","sel.last")
     }
  };
 $w->insert('insert',$s);
 $w->see('insert')
}

1;
