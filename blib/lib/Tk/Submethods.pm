package Tk::Submethods;

use vars qw($VERSION);
$VERSION = '3.009'; # $Id: //depot/Tk8/Tk/Submethods.pm#9$

sub import
{
 my $class = shift;
 no strict 'refs';
 my $package = caller(0);
 while (@_)
  {
   my $fn = shift;
   my $sm = shift;
   my $sub;
   foreach $sub (@{$sm})
    {
     my ($suffix) = $sub =~ /(\w+)$/;
     *{$package.'::'."$fn\u$suffix"} = sub { shift->$fn($sub,@_) };
    }
  }
}

sub Direct
{
 my $class = shift;
 no strict 'refs';
 my $package = caller(0);
 while (@_)
  {
   my $fn = shift;
   my $sm = shift;
   my $sub;
   foreach $sub (@{$sm})
    {
     # eval "sub ${package}::${sub} { shift->$fn('$sub',\@_) }";
     *{$package.'::'.$sub} = sub { shift->$fn($sub,@_) };
    }
  }
}

1;

__END__

=cut
