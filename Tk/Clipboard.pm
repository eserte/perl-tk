# Copyright (c) 1995-1999 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Clipboard;
use strict;

use vars qw($VERSION);
$VERSION = '3.014'; # $Id: //depot/Tk8/Tk/Clipboard.pm#14$

use AutoLoader qw(AUTOLOAD);
use Tk qw(catch);

sub clipEvents
{
 return qw[Copy Cut Paste];
}

sub ClassInit
{
 my ($class,$mw) = @_;
 foreach my $op ($class->clipEvents)
  {
   $mw->Tk::bind($class,"<<$op>>","clipboard$op");
  }
 return $class;
}

sub clipboardSet
{
 my $w = shift;
 $w->clipboardClear;
 $w->clipboardAppend(@_);
}

sub clipboardCopy
{
 my $w = shift;
 my $val = $w->getSelected;
 if (defined $val)
  {
   $w->clipboardSet('--',$val);
  }
 return $val;
}

sub clipboardCut
{
 my $w = shift;
 my $val = $w->clipboardCopy;
 if (defined $val)
  {
   $w->deleteSelected;
  }
 return $val;
}

sub clipboardGet
{
 my $w = shift;
 $w->SelectionGet('-selection','CLIPBOARD',@_);
}

sub clipboardPaste
{
 my $w = shift;
 local $@;
 catch { $w->insert('insert',$w->clipboardGet)};
}

sub clipboardOperations
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
 while (@_)
  {
   my $op = shift;
   $mw->Tk::bind(@class,"<<$op>>","clipboard$op");
  }
}

# These methods work for Entry and Text
# and can be overridden where they don't work

sub deleteSelected
{
 my $w = shift;
 catch { $w->delete('sel.first','sel.last') };
}


1;
__END__

sub getSelected
{
 my $w   = shift;
 my $val = Tk::catch { $w->get('sel.first','sel.last') };
 return $val;
}


