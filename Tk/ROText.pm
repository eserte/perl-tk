# Copyright (c) 1995-1998 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
require Tk;
package Tk::ROText;
require Tk::Text;

use vars qw($VERSION @ISA);
$VERSION = '3.007'; # $Id: //depot/Tk8/Tk/ROText.pm#7$

@ISA = qw(Tk::Text);
Construct Tk::Widget 'ROText';

sub clipEvents
{
 return qw[Copy];
}

sub ClassInit
{
 my ($class,$mw) = @_;
 my $val = $class->bindRdOnly($mw);
 my $cb  = $mw->bind($class,'<Next>');
 $mw->bind($class,'<space>',$cb) if (defined $cb);
 $cb  = $mw->bind($class,'<Prior>');
 $mw->bind($class,'<BackSpace>',$cb) if (defined $cb);
 return $val;
}

sub Tk::Widget::ScrlROText { shift->Scrolled('ROText' => @_) }

1;

__END__

=head1 NAME

Tk::ROText - 'readonly' perl/tk Text widget

=head1 SYNOPSIS

    use Tk::ROText;
    ...
    $ro = $mw->ROText(?options,...?);

=head1 DESCRIPTION

This IS-A text widget with all bindings removed that would alter the contents
of the text widget.

=head1 KEYS

widget, text, readonly

=head1 SEE ALSO

Tk::Text(3)

