package Tk::OlWm;

use vars qw($VERSION);
$VERSION = '2.004'; # $Id: //depot/Tk/Contrib/OlWm.pm#4$

use Tk;
use 5.004;

# Decoration that can be added/deleted 
# 
# CLOSE FOOTER HEADER RESIZE PIN ICON_NAME

sub ADDDEL
{
 my ($mw,$atom,$to,$from) = @_;
 my $data = $mw->privateData;
 $data->{$to} = {} unless exists $data->{$to};
 $data->{$to}->{$atom} = 1;
 $data->{$from}->{$atom} if (exists $data->{$from});
}

sub Update
{
 my $mw = shift;
 my $data = $mw->privateData;
 foreach my $kind (keys %$data)
  {
   $mw->property('set',"_OL_DECOR_$kind",ATOM,32,[keys %{$data->{$kind}}]);
  }
}

sub Flag
{
 my ($name,$mw,$state) = @_;
 $mw->property('set',"_OL_$name",INTEGER,32,$state);
 $mw->update if ($mw->IsMapped);
}

sub Tk::Wm::OL_WIN_BUSY
{
 Flag('WIN_BUSY',@_);
}

sub Tk::Wm::OL_PIN_STATE
{
 Flag('PIN_STATE',@_);
}


sub Tk::Wm::OL_DECOR
{
 my ($mw,%args) = @_;
 foreach (keys %args)
  {
   my $atom = "_OL_DECOR_$_";
   if ($args{$_})
    {
     ADDDEL($mw,$atom,'ADD','DEL');
    }
   else
    {
     ADDDEL($mw,$atom,'DEL','ADD');
    }
  }
 Update($mw);
}

1;

__END__

=head1 NAME

Tk::OlWm - Interface to OpenLook properties of toplevel windows.

=head1 SYNOPSIS

   use Tk::OlWm;

   $toplevel->OL_DECOR( 
                        CLOSE  => flag,
                        FOOTER => flag,
                        HEADER => flag, 
                        RESIZE => flag, 
                        PIN => flag, 
                        ICON_NAME => flag, 
                      );

   $toplevel->OL_WIN_BUSY( flag );

   $toplevel->OL_PIN_STATE( flag );


=head1 DESCRIPTION

I simple perl-only module that adds a few methods to Tk::Wm class.
These methods manipulate properties of the C<$toplevel> to communicate 
with an OpenLook window manager, e.g. Sun's C<olwm> or C<olvwm>.

In the synopsis above C<flag> is a "boolean" value - i.e. an integer 
with 0 meaning false and other values meaning true.

All the I<name =E<gt> flag> pairs are optional.

=head1 STATUS

Works for me, it is in 'Contrib' because I cannot support something
which has been developed just by dumping properties of Sun applications
and guessing.

=head1 AUTHOR

Nick Ing-Simmons E<lt>nik@tiuk.ti.comE<gt>

=cut


