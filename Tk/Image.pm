package Tk::Image;

use Carp;

# This module does for images what Tk::Widget does for widgets:
# provides a base class for them to inherit from.

@ISA = qw(Tk); # but are they ?

sub new
{
# print "new(",join(',',@_),")\n";
 my $package = shift;
 my $widget  = shift;
 my $leaf = $package->Tk_image;
 my $obj = eval { $widget->image('create',$leaf,@_) };
 croak "$package: $@" if ($@);
 $obj = \"$obj" unless (ref $obj);
 return bless $obj,$package;
}

BEGIN 
{
 my $fn;
 foreach $fn (qw(delete width height type))
  {
   *{"$fn"} = sub { shift->image("$fn",@_) }; 
  }
}

sub Construct
{
 my ($base,$name) = @_;
 my $class = (caller(0))[0];
#print "$base->$name is $class\n";
 @{"${class}::Inherit::ISA"} = @{"${class}::ISA"};
 *{"Tk::Widget::$name"}  = sub { $class->new(@_) };
}

# This is here to prevent AUTOLOAD trying to find it.
sub DESTROY
{
 my $i = shift;
 # maybe do image delete ???
}


1; 
