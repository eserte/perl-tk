# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub Unbusy
{
 my ($w) = @_;
 $w->grabRelease;
 my $old = delete $w->{'Busy'};
 if (defined $old)
  {
   my $grab = delete $old->{'grab'};
   $w->update;  # flush events that happened with Busy bindings
   $w->bindtags(delete $old->{'bindtags'});
   $w->Tk::configure(%{$old}); 
   $w->update;
   &$grab;
  }
}

1;
