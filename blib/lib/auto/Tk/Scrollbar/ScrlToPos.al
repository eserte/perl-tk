# NOTE: Derived from .././blib/lib/Tk/Scrollbar.pm.  Changes made here will be lost.
package Tk::Scrollbar;

# tkScrlToPos --
# This procedure tells the scrollbar's associated widget to scroll to
# a particular location, given by a fraction between 0 and 1.  It notifies
# the associated widget in different ways for old and new command syntaxes.
#
# Arguments:
# w -		The scrollbar widget.
# pos -		A fraction between 0 and 1 indicating a desired position
#		in the document.

sub ScrlToPos
{
 my $w = shift;
 my $pos = shift;
 my $cmd = $w->cget("-command");
 return unless (defined $cmd);
 my @info = $w->get;
 if (@info == 2)
  {
   $cmd->Call("moveto",$pos);
  }
 else
  {
   $cmd->Call(int($info[0]*$pos));
  }
}

1;
