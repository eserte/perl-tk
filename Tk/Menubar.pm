package Tk::Menubar;
require Tk::Frame;
@ISA = qw(Tk::Frame);

Tk::Widget->Construct('Menubar');

# Just make it a Frame until we figure out what else
# it should do.

sub Populate
{
 my ($cw,$args) = @_;
 $cw->SUPER::Populate($args);
}

sub command
{
 my ($cw,%args) = @_;
 my $button = delete $args{-button};
 $button = ['Misc', -underline => 0 ] unless (defined $button);
 my @bargs = ();
 ($button,@bargs) = @$button if (ref($button) && ref $button eq 'ARRAY');
 unless (defined $cw->Subwidget($button))
  {
   $cw->Component(Menubutton => $button, -text => $button, 
                  '-pack' => [ -side => 'left', -fill => 'y' ], @bargs);
  }
 $cw->Subwidget($button)->command(%args);
}

1;
