# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

# This is supposed to replicate Tk::after behaviour,
# but does auto-cancel when widget is deleted.


sub after
{
 require Tk::After;
 my $w = shift;
 my $t = shift;
 if (@_)
  {
   return Tk::After->new($w,$t,'once',@_) if ($t ne 'cancel');
   while (@_)
    {
     my $what = shift;
     if (ref $what)
      {
       $what->cancel;
      }
     else
      {
       carp "dubious cancel of $what";
       $w->Tk::after('cancel' => $what);
      }
    }
  }
 else
  {
   $w->Tk::after($t);
  }
}

1;
