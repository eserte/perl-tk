package Tk::Image;

# This module does for images what Tk::Widget does for widgets:
# provides a base class for them to inherit from.

@Tk::Image::ISA = qw(Tk); # but are they ?

sub new
{
 my $package = shift;
 my $widget  = shift;
 my $leaf = $package->Tk_image;
 my $obj = eval { $widget->image('create',$leaf,@_) };
 $widget->BackTrace($@) if ($@);
 return bless $obj,$package;
}

BEGIN 
{
 my $fn;
 foreach $fn (qw(delete width height type))
  {
   *{"$fn"} = sub { shift->image($fn,@_) }; 
  }
}

sub Tk::Widget::imageNames
{
 my $w = shift;
 $w->image('names',@_);
}

sub Tk::Widget::imageTypes
{
 my $w = shift;
 map("\u$_",$w->image('types',@_));
}

sub Construct
{
 my ($base,$name) = @_;
 my $class = (caller(0))[0];
 *{"Tk::Widget::$name"}  = sub { $class->new(@_) };
}

# This is here to prevent AUTOLOAD trying to find it.
sub DESTROY
{
 my $i = shift;
 # maybe do image delete ???
}


1; 
