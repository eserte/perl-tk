# NOTE: Derived from .././blib/lib/Tk/Ghostscript.pm.  Changes made here will be lost.
package Tk::Ghostscript;

sub BoundingBox
{
 my $w = shift;
 return @{$w->{'BoundingBox'}} unless (@_);
 croak "Invalid bounding box" . Pretty(\@_) unless (@_ == 4); 
 my @bb = @_;
 $w->{'BoundingBox'} = \@bb;
 $w->ChangeView;
}

1;
