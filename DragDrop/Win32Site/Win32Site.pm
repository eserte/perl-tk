package Tk::DragDrop::Win32Site;
require DynaLoader;
require Tk::DropSite;

use vars qw($VERSION);
$VERSION = '3.004'; # $Id: //depot/Tk8/DragDrop/Win32Site/Win32Site.pm#4$

use base qw(Tk::DropSite DynaLoader);

bootstrap Tk::DragDrop::Win32Site $Tk::VERSION;

use strict;

Tk::DropSite->Type('Win32');

sub WM_DROPFILES () {563}

sub InitSite
{
 my ($class,$site) = @_;
 my $w = $site->widget;
 $w->BindClientMessage(WM_DROPFILES,[\&Win32Drop,$site]);
 DragAcceptFiles($w,1);
 warn "Enable $w";
}

sub Win32Drop
{
 print join(',',@_),"\n";
 my ($w,$site,$msg,$wParam,$lParam) = @_;
 my ($x,$y,@files) = DropInfo($wParam);
 my $cb = $site->{'-dropcommand'};
 if ($cb)
  {
   foreach my $file (@files)
    {
     print "$file @ $x,$y\n";
     $w->clipboardClear;
     $w->clipboardAppend('--',$file);
     $cb->Call('CLIPBOARD',$x,$y);
    }
  }
 return 0;
}

1;
__END__