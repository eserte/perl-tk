# NOTE: Derived from blib/lib/Tk.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk;

#line 373 "blib/lib/Tk.pm (autosplit into blib/lib/auto/Tk/exit.al)"
# provide an exit() to be exported if exit occurs
# before a MainWindow->new()
sub exit { CORE::exit(@_);}

# end of Tk::exit
1;
