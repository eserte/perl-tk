package Tk::widgets;
use Carp;

use vars qw($VERSION);
$VERSION = '3.008'; # $Id: //depot/Tk8/Tk/widgets.pm#8$

sub import
{
 my $class = shift;
 foreach (@_)
  {
   local $SIG{__DIE__} = \&Carp::croak;
   # carp "$_ already loaded" if (exists $INC{"Tk/$_.pm"});
   require "Tk/$_.pm";
  }
}

1;
__END__

=head1 NAME

Tk::widgets - preload widget classes

=for category Implementation

=head1 SYNOPSIS

  use Tk::widgets qw(Button Label Frame);

=head1 DESCRIPTION

Does a 'require Tk::Foo' for each 'Foo' in the list.
May speed startup by avoiding AUTOLOADs.

=cut
