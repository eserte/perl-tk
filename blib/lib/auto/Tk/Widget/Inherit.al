# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub Inherit
{
 carp "Inherit is deprecated - use SUPER::";
 my $w = shift;
 my $method = shift;
 my ($class) = caller;
 *{$class.'::Inherit::ISA'} = \@{$class.'::ISA'} unless (defined @{$class.'::Inherit::ISA'});
 $class .= '::Inherit::';
 $class .= $method;
 return $w->$class(@_);
}

1;
