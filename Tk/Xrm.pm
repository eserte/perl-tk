package Tk::Xrm;
use Tk ();
1;
__END__

=head1 NAME

Tk::Xrm - X Resource/Defaults/Options routines that obey the rules.

=head1 SYNOPSIS

   use Tk;
   use Tk::Xrm;  

=head1 DESCRIPTION

Using this modules causes Tk's Option code to be replaced by versions
which use routines from <X11/Xresource.h> - i.e. same ones every other
X toolkit uses.

Result is that "matching" of name/Class with the options database follows
the same rules as other X toolkits. This makes it more predictable, 
and makes it easier to have a single ~/.Xdefaults file which gives sensible
results for both Tk and (say) Motif applications.

=head1 BUGS 

Currently C<optionAdd('key' => 'value' [, priority])> ignores optional
priority completely and just does XrmPutStringResource().
Perhaps it should be more subtle and do XrmMergeDatabases() or 
XrmCombineDatabase().

This version is a little slower than Tk's re-invention but there is 
more optimization that can be done.

=cut


