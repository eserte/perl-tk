# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

# Some convenience methods 

sub menu
{
 my ($w,%args) = @_;
 my $menu = $w->cget('-menu');
 if (!defined $menu)
  {
   require Tk::Menu;
   $w->ColorOptions(\%args); 
   $menu = $w->Menu(%args);
   $w->configure('-menu'=>$menu);
  }
 else
  {
   $menu->configure(%args);
  }
 return $menu;
}

1;
