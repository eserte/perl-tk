# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

# provide an exit() to be exported if exit occurs 
# before a MainWindow->new()
sub exit { CORE::exit(@_);}

1;
