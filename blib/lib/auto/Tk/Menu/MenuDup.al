# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# tkMenuDup --
# Given a menu (hierarchy), create a duplicate menu (hierarchy)
# in a given window.
#
# Arguments:
# src - Source window. Must be a menu. It and its
# menu descendants will be duplicated at dst.
# dst - Name to use for topmost menu in duplicate
# hierarchy.
sub MenuDup
{
 my $src    = shift;
 my $parent = shift;
 my @args   = ();
 my $option;
 foreach $option ($src->configure())
  {
   next if (@$option == 2);
   push(@args,$$option[0],$$option[4]);
  }
 my $dst = $parent->Menu(@args);
 my $last = $src->index("last");
 return if ($last eq 'none');
 my $i;
 for ($i = $src->cget("-tearoff");$i <= $last;$i += 1)
  {
   my $type = $src->type($i);
   if (defined $type)
    {
     @args = ();
     foreach $option ($src->entryconfigure($i))
      {
       next if (@$option == 2);
       push(@args,$$option[0],$$option[4]) if (defined $$option[4]);
      }
     $dst->add($type,@args);
     if ($type eq "cascade")
      {
       my $srcm = $src->entrycget($i,"-menu");
       if (defined $srcm)
        {
         $dst->entryconfigure($i,"-menu",$srcm->MenuDup($dst));
        }
      }
     elsif ($type eq "checkbutton" || $type eq "radiobutton")
      {
       $dst->entryconfigure($i,"-variable",$src->entrycget($i,"-variable"));
      }
    }
  }
 return $dst;
}

1;
