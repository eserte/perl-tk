# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub Palette
{
 my $w = shift->MainWindow;
 unless (exists $w->{_Palette_})
  {
   my %Palette = ();
   my $c = $w->Checkbutton();
   my $e = $w->Entry();
   my $s = $w->Scrollbar();
   $Palette{"activeBackground"}    = ($c->configure("-activebackground"))[3] ;
   $Palette{"activeForeground"}    = ($c->configure("-activeforeground"))[3];
   $Palette{"background"}          = ($c->configure("-background"))[3];
   $Palette{"disabledForeground"}  = ($c->configure("-disabledforeground"))[3];
   $Palette{"foreground"}          = ($c->configure("-foreground"))[3];
   $Palette{"highlightBackground"} = ($c->configure("-highlightbackground"))[3];
   $Palette{"highlightColor"}      = ($c->configure("-highlightcolor"))[3];
   $Palette{"insertBackground"}    = ($e->configure("-insertbackground"))[3];
   $Palette{"selectColor"}         = ($c->configure("-selectcolor"))[3];
   $Palette{"selectBackground"}    = ($e->configure("-selectbackground"))[3];
   $Palette{"selectForeground"}    = ($e->configure("-selectforeground"))[3];
   $Palette{"troughColor"}         = ($s->configure("-troughcolor"))[3];
   $c->destroy;
   $e->destroy;
   $s->destroy;
   $w->{_Palette_} = \%Palette;
  }
 return $w->{_Palette_};
}

1;
