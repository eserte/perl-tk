# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub InheritThis
{
 carp "InheritThis is deprecated - use SUPER::";
 my $w      = shift;
 my $what   = (caller(1))[3];
 my ($class,$method) = $what =~ /^(.*)::([^:]+)$/;
 *{$class.'::Inherit::ISA'} = \@{$class.'::ISA'} unless (defined @{$class.'::Inherit::ISA'});
 $class .= '::Inherit::';
 $class .= $method;
 return $w->$class(@_);
}

1;
