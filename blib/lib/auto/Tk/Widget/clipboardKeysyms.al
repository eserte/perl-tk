# NOTE: Derived from blib/lib/Tk/Widget.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Widget;

#line 1143 "blib/lib/Tk/Widget.pm (autosplit into blib/lib/auto/Tk/Widget/clipboardKeysyms.al)"
# clipboardKeysyms --
# This procedure is invoked to identify the keys that correspond to
# the "copy", "cut", and "paste" functions for the clipboard.
#
# Arguments:
# copy - Name of the key (keysym name plus modifiers, if any,
# such as "Meta-y") used for the copy operation.
# cut - Name of the key used for the cut operation.
# paste - Name of the key used for the paste operation.
#
# This method is obsolete use clipboardOperations and abstract
# event types instead. See Clipboard.pm and Mainwindow.pm

sub clipboardKeysyms
{
 my @class = ();
 my $mw    = shift;
 if (ref $mw)
  {
   $mw = $mw->DelegateFor('bind');
  }
 else
  {
   push(@class,$mw);
   $mw = shift;
  }
 if (@_)
  {
   my $copy  = shift;
   $mw->Tk::bind(@class,"<$copy>",'clipboardCopy')   if (defined $copy);
  }
 if (@_)
  {
   my $cut   = shift;
   $mw->Tk::bind(@class,"<$cut>",'clipboardCut')     if (defined $cut);
  }
 if (@_)
  {
   my $paste = shift;
   $mw->Tk::bind(@class,"<$paste>",'clipboardPaste') if (defined $paste);
  }
}

# end of Tk::Widget::clipboardKeysyms
1;
