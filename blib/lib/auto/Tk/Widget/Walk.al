# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub Walk 
{
 # Traverse a widget hierarchy while executing a subroutine.
 my($cw, $proc, @args) = @_;
 my $subwidget;
 foreach $subwidget ($cw->children) 
  {
   $subwidget->Walk($proc,@args);
   &$proc($subwidget, @args);
  }
} # end walk

1;
