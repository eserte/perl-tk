# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub Descendants
{
 # Return a list of widgets derived from a parent widget and all its
 # descendants of a particular class.  
 # If class is not passed returns the entire widget hierarchy.
 
 my($widget, $class) = @_;
 my(@widget_tree)    = ();
 
 $widget->Walk(
               sub { my ($widget,$list,$class) = @_;
                     push(@$list, $widget) if  (!defined($class) or $class eq $widget->class);
                   }, 
               \@widget_tree, $class
              );
 return @widget_tree;
} 

1;
