# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

# tkRecolorTree --
# This procedure changes the colors in a window and all of its
# descendants, according to information provided by the colors
# argument. It only modifies colors that have their default values
# as specified by the Tk::Palette variable.
#
# Arguments:
# w - The name of a window. This window and all its
# descendants are recolored.
# colors - The name of an array variable in the caller,
# which contains color information. Each element
# is named after a widget configuration option, and
# each value is the value for that option.
sub RecolorTree
{
 my ($w,$colors) = @_;
 my $dbOption;
 local ($@);
 my $Palette = $w->Palette;
 foreach $dbOption (keys %$colors)
  {
   my $option = "-\L$dbOption";
   my $value;
   eval {local $SIG{'__DIE__'}; $value = $w->cget($option) };
   if (defined $value)
    {
     if ($value eq $Palette->{$dbOption})
      {
       $w->configure($option,$colors->{$dbOption})
      }
    }
  }
 my $child;
 foreach $child ($w->children)
  {
   $child->RecolorTree($colors);
  }
}

1;
