# Copyright (c) 1995-1996 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Image;

# This module does for images what Tk::Widget does for widgets:
# provides a base class for them to inherit from.
require DynaLoader;

@Tk::Image::ISA = qw(DynaLoader Tk); # but are they ?

sub new
{
 my $package = shift;
 my $widget  = shift;
 my $leaf = $package->Tk_image;
 my $obj = $widget->image('create',$leaf,@_);
 return bless $obj,$package;
}

require Tk::Submethods;

Direct Tk::Submethods ('image' => [qw(delete width height type)]);

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
