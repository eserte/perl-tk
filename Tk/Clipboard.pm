package Tk::Widget;

sub clipboardSet
{
 my $w = shift;
 $w->clipboardClear;
 $w->clipboardAppend(@_);
}

sub clipboardCopy
{
 my $w = shift;
 if ($w->IS($w->SelectionOwner))
  {
   $w->clipboardSet($w->SelectionGet);
  }
}

sub clipboardCut
{
 my $w = shift;
 if ($w->IS($w->SelectionOwner))
  {
   $w->clipboardSet($w->SelectionGet);
   $w->deleteSelected;
  }
}

sub clipboardGet
{
 my $w = shift;
 $w->SelectionGet("-selection","CLIPBOARD",@_);
}

sub clipboardPaste
{
 my $w = shift;
 local ($@);
 eval {$w->insert("insert",$w->clipboardGet)};
 $w->BackTrace($@) if ($@);
}

# clipboardKeysyms --
# This procedure is invoked to identify the keys that correspond to
# the "copy", "cut", and "paste" functions for the clipboard.
#
# Arguments:
# copy - Name of the key (keysym name plus modifiers, if any,
# such as "Meta-y") used for the copy operation.
# cut - Name of the key used for the cut operation.
# paste - Name of the key used for the paste operation.


sub clipboardKeysyms
{
 my $class = shift;
 my $mw    = shift;
 if (@_)
  {
   my $copy  = shift;
   $mw->Tk::bind($class,"<$copy>",'clipboardCopy')   if (defined $copy);
  }
 if (@_)
  {
   my $cut   = shift;
   $mw->Tk::bind($class,"<$cut>",'clipboardCut')     if (defined $cut);
  }
 if (@_)
  {
   my $paste = shift;                                                
   $mw->Tk::bind($class,"<$paste>",'clipboardPaste') if (defined $paste);
  }
}

1;
