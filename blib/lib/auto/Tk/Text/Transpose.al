# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub Transpose
{
 my ($w) = @_;
 my $pos = 'insert';
 $pos = $w->index("$pos + 1 char") if ($w->compare($pos,'!=',"$pos lineend"));
 return if ($w->compare("$pos - 1 char",'==','1.0'));
 my $new = $w->get("$pos - 1 char").$w->get("$pos - 2 char");
 $w->delete("$pos - 2 char",$pos);
 $w->insert('insert',$new); 
 $w->see('insert');
}

1;
