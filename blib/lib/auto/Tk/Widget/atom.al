# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

# atom, atomname, containing, interps, pathname 
# don't work this way - there is no window arg
# So we pretend there was an call the C versions from Tk.xs

sub atom       { shift->InternAtom(@_)  }
1;
