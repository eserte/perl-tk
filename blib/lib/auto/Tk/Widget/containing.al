# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub containing { shift->Containing(@_)  }


# interps not done yet
# pathname not done yet

# walk and descendants adapted from Stephen's composite
# versions as they only use core features they can go here.
# hierachy is reversed in that descendants calls walk rather
# than vice versa as this avoids building a list.
# Walk should possibly be enhanced so allow early termination
# like '-prune' of find.

1;
